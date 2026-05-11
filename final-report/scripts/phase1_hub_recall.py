"""
§1.8 Hub-recall task (Mode A — pre-proof).

Given a problem statement and the catalog of 22 hub-strategies, ask the model
to predict which hubs apply. Score precision/recall against the ground-truth
hub edges in the dataset.

Quantifies the dataset's relational contribution: even given the full hub
catalog as context, does the model recover the human-curated connections?
"""

from __future__ import annotations

import json
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unified_harness import run_attempt

DATASET_DIR = Path("/workspace/final-presentation/d2_curation_v2/data/dataset_v2")
NODES_DIR = DATASET_DIR / "nodes"
EDGES_FILE = DATASET_DIR / "edges.json"
AUDIT_FILE = Path("/workspace/final-report/data/phase1_smoke/formalization_audit.json")
OUT_DIR = Path("/workspace/final-report/data/phase1_hub_recall")
OUT_DIR.mkdir(parents=True, exist_ok=True)

import os
# Default to the two strong models only — small/reasoning models are slow per call
# and we want to validate the mechanism before scaling. Override via HR_MODELS env var.
_default_models = "gpt-5.5,claude-opus-4-7"
MODELS = os.environ.get("HR_MODELS", _default_models).split(",")
N_PROBLEMS = int(os.environ.get("HR_N", "10"))


def load_hubs() -> list[dict]:
    """Load all 22 hub nodes."""
    hubs = []
    for f in sorted(NODES_DIR.glob("*-hub.json")):
        n = json.loads(f.read_text())
        if n.get("type") != "hub":
            continue
        # Build a compact description: name + first-strategy summary + applicability
        strategies = n.get("strategies", [])
        first = strategies[0] if strategies else {}
        hubs.append({
            "id": n["id"],
            "english_title": n.get("english_source_note") or first.get("strategy_name_en", ""),
            "summary": first.get("summary_en", "")[:300],
            "applicability": first.get("applicability", "")[:200],
        })
    return hubs


def build_ground_truth() -> dict[str, set[str]]:
    """Map problem_id -> set of hub_ids that connect to it."""
    edges = json.loads(EDGES_FILE.read_text())
    hub_ids = set()
    for f in NODES_DIR.glob("*-hub.json"):
        n = json.loads(f.read_text())
        if n.get("type") == "hub":
            hub_ids.add(n["id"])
    gt: dict[str, set[str]] = {}
    for e in edges:
        a, b = e["a"], e["b"]
        if a in hub_ids and b not in hub_ids:
            gt.setdefault(b, set()).add(a)
        elif b in hub_ids and a not in hub_ids:
            gt.setdefault(a, set()).add(b)
    return gt


def load_problem_pool() -> list[dict]:
    """Load FAITHFUL problems from the audit (148 candidates)."""
    audit = json.loads(AUDIT_FILE.read_text())
    return [r for r in audit if r["verdict"] == "FAITHFUL"]


PROMPT_TEMPLATE = """You are given a math problem and a catalog of {n_hubs} strategy hubs.
Each hub represents a recurring proof technique or methodological pattern. Your
task: identify which hub(s) apply to the given problem. Multiple hubs may apply.

PROBLEM STATEMENT:
{statement_en}

HUB CATALOG:
{hub_catalog}

Output ONLY a JSON object on a single line, no markdown, no commentary:
{{"hubs": ["hub-id-1", "hub-id-2", ...], "rationale": "<brief one-sentence justification>"}}

Use the exact hub IDs from the catalog. Empty list `[]` is valid if you believe no hub applies."""


def render_hub_catalog(hubs: list[dict]) -> str:
    lines = []
    for h in hubs:
        lines.append(f"- {h['id']}")
        lines.append(f"    name: {h['english_title']}")
        if h["summary"]:
            lines.append(f"    summary: {h['summary']}")
        if h["applicability"]:
            lines.append(f"    applies when: {h['applicability']}")
    return "\n".join(lines)


def parse_response(text: str) -> dict:
    """Extract first JSON object with 'hubs' key."""
    if not text:
        return {"hubs": [], "rationale": "empty response", "_error": "empty"}
    m = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", text, re.DOTALL)
    s = m.group(1).strip() if m else text.strip()
    m = re.search(r"\{[^{}]*\"hubs\"[^{}]*\}", s, re.DOTALL)
    if not m:
        # try broader
        m = re.search(r"\{.*\}", s, re.DOTALL)
    if not m:
        return {"hubs": [], "rationale": "no json", "_error": f"no_json: {text[:120]!r}"}
    try:
        d = json.loads(m.group(0))
        return {
            "hubs": list(d.get("hubs", [])),
            "rationale": d.get("rationale", ""),
        }
    except Exception as e:
        return {"hubs": [], "rationale": "", "_error": f"parse_failed: {e}"}


def score(predicted: list[str], ground_truth: set[str]) -> dict:
    pred = set(predicted)
    if not pred and not ground_truth:
        return {"precision": 1.0, "recall": 1.0, "tp": 0, "fp": 0, "fn": 0,
                "predicted": list(pred), "ground_truth": list(ground_truth)}
    tp = len(pred & ground_truth)
    fp = len(pred - ground_truth)
    fn = len(ground_truth - pred)
    p = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    r = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    return {"precision": p, "recall": r, "tp": tp, "fp": fp, "fn": fn,
            "predicted": sorted(pred), "ground_truth": sorted(ground_truth)}


def run_one(problem: dict, hubs: list[dict], gt: set[str], hub_catalog_str: str, model: str) -> dict:
    prompt = PROMPT_TEMPLATE.format(
        n_hubs=len(hubs),
        statement_en=problem["statement_en"][:1500],
        hub_catalog=hub_catalog_str,
    )
    t0 = time.time()
    result = run_attempt(model, prompt)
    wall = time.time() - t0
    text = result.get("response_text") or ""
    parsed = parse_response(text)
    s = score(parsed["hubs"], gt)
    return {
        "problem_id": problem["problem_id"],
        "model": model,
        "wall_seconds": round(wall, 1),
        "predicted": s["predicted"],
        "ground_truth": s["ground_truth"],
        "precision": s["precision"],
        "recall": s["recall"],
        "tp": s["tp"],
        "fp": s["fp"],
        "fn": s["fn"],
        "rationale": parsed.get("rationale", ""),
        "raw_excerpt": text[:300],
    }


def main():
    hubs = load_hubs()
    gt_map = build_ground_truth()
    problems = load_problem_pool()

    # Filter to problems that have at least 1 ground-truth hub edge (otherwise scoring is trivial)
    problems_with_gt = [p for p in problems if gt_map.get(p["problem_id"])]
    print(f"Hubs: {len(hubs)}")
    print(f"Faithful problems with ≥1 hub edge: {len(problems_with_gt)}")
    print()

    # Sample N
    import random
    random.seed(42)
    sample = random.sample(problems_with_gt, min(N_PROBLEMS, len(problems_with_gt)))
    print(f"Running hub-recall on {len(sample)} problems × {len(MODELS)} models ({len(sample)*len(MODELS)} calls)")
    print()

    hub_catalog_str = render_hub_catalog(hubs)

    results = []
    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {}
        for p in sample:
            gt = gt_map.get(p["problem_id"], set())
            for m in MODELS:
                futures[ex.submit(run_one, p, hubs, gt, hub_catalog_str, m)] = (p["problem_id"], m)
        for fut in as_completed(futures):
            pid, m = futures[fut]
            try:
                r = fut.result()
                results.append(r)
                print(f"  {m:<22} {pid:<40} P={r['precision']:.2f} R={r['recall']:.2f}  pred={r['predicted'][:3]} gt={r['ground_truth'][:3]}")
            except Exception as e:
                print(f"  [ERR] {m} {pid}: {e}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "results.json").write_text(json.dumps(results, indent=2, ensure_ascii=False))

    # Aggregate per model
    print()
    print("=== HUB-RECALL LEADERBOARD ===")
    print(f"{'model':<22} {'avg P':>8} {'avg R':>8} {'avg F1':>8}  (n={len(sample)})")
    print("-" * 60)
    for m in MODELS:
        rs = [r for r in results if r["model"] == m]
        if not rs: continue
        avg_p = sum(r["precision"] for r in rs) / len(rs)
        avg_r = sum(r["recall"] for r in rs) / len(rs)
        avg_f = (2 * avg_p * avg_r / (avg_p + avg_r)) if (avg_p + avg_r) > 0 else 0.0
        print(f"{m:<22} {avg_p:>8.3f} {avg_r:>8.3f} {avg_f:>8.3f}")
    print()
    print(f"Artifacts: {OUT_DIR}/results.json")


if __name__ == "__main__":
    main()
