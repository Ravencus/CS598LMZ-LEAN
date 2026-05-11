#!/usr/bin/env python3
"""Phase B: hub-recall task using Codex CLI.

For each manifest problem, prompt a model with:
  - the theorem statement (English + Lean signature)
  - the full list of 22 knowledge hubs (id + name + strategy summaries)
  - "select the relevant hub ids as a JSON array"

Then compare the model's selection to the manifest's ground_truth_hubs and
compute precision/recall/F1 per problem and aggregate.

Output: data/eval_overnight_opencode/hub_recall/{model}/<pid>/result.json
        data/eval_overnight_opencode/hub_recall/{model}/aggregate.json
"""
from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
HUBS_DIR = REPO_ROOT / "final-presentation" / "d2_curation_v2" / "data" / "dataset_v2" / "nodes"
SNAPSHOT_DIR = REPO_ROOT / "final-report" / "data" / "eval_snapshots" / "20260510_083526_partial"
DEFAULT_MANIFEST = SNAPSHOT_DIR / "manifest.json"
EVAL_DIR = REPO_ROOT / "final-report" / "data" / "eval_overnight_opencode" / "hub_recall"
CODEX_BIN = "codex"

DEFAULT_WALL_S = 180
DEFAULT_PARALLEL = 8
DEFAULT_MODEL = "gpt-5.5"


def load_hubs() -> list[dict]:
    """Return list of hub records, lightly trimmed for prompt size."""
    hubs: list[dict] = []
    for path in sorted(HUBS_DIR.glob("*-hub.json")):
        d = json.loads(path.read_text(encoding="utf-8"))
        # Compact strategies: keep title + summary + applicability for first 4.
        strategies = []
        for s in (d.get("strategies") or [])[:4]:
            t = (s.get("english_title") or s.get("strategy_name_en") or "").strip()
            summary = (s.get("summary_en") or "").strip()
            applic = (s.get("applicability") or "").strip()
            strategies.append({
                "title": t,
                "summary": summary[:400],
                "applies_when": applic[:300],
            })
        hubs.append({
            "id": d["id"],
            "name": d.get("english_source_note") or d["id"],
            "is_top3": bool(d.get("is_top3")),
            "strategies": strategies,
        })
    return hubs


def render_hub_block(hubs: list[dict]) -> str:
    parts = []
    for h in hubs:
        parts.append(f"### `{h['id']}` — {h['name']}" + (" (TOP-3)" if h['is_top3'] else ""))
        for i, s in enumerate(h["strategies"], 1):
            parts.append(f"  {i}. {s['title']}: {s['summary']} (applies: {s['applies_when']})")
        parts.append("")
    return "\n".join(parts)


PROMPT_TEMPLATE = """You are tagging a Lean theorem with which "knowledge hubs" from an analysis-strategy taxonomy are relevant to proving it. Each hub represents a strategy family (e.g., "term-by-term estimates", "Cauchy condensation test").

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE:
{signature_block}

The full hub catalogue (22 hubs total, with strategies):

{hub_block}

TASK: choose the SUBSET of hubs whose strategies/methods are genuinely needed (or strongly relevant) to prove the theorem above. Be selective — typical answers are 2-6 hubs. Do not include a hub just because it sounds vaguely related.

OUTPUT FORMAT: a single JSON array of hub IDs (kebab-case, ending with `-hub`) on a single line, then a one-sentence justification per hub.

Example output:
["term-by-term-estimates-hub", "cauchy-condensation-test-hub"]
- term-by-term-estimates-hub: ...
- cauchy-condensation-test-hub: ...
"""


PROMPT_TEMPLATE_PROOF = """You are tagging a Lean theorem with which "knowledge hubs" from an analysis-strategy taxonomy are relevant to proving it. Each hub represents a strategy family (e.g., "term-by-term estimates", "Cauchy condensation test"). For this task you are given the FULL completed Lean 4 proof and must identify which hubs' strategies appear in it.

THEOREM (English):
{statement_en}

LEAN 4 PROOF (complete, type-checked):
```lean
{final_proof}
```

The full hub catalogue (22 hubs total, with strategies):

{hub_block}

TASK: read the proof above and choose the SUBSET of hubs whose strategies are actually used (or whose techniques the proof relies on). Base the selection on what the proof does, not on what the theorem statement merely suggests. Be selective; typical answers are 2-6 hubs.

OUTPUT FORMAT: a single JSON array of hub IDs (kebab-case, ending with `-hub`) on a single line, then a one-sentence justification per hub citing the proof step.

Example output:
["term-by-term-estimates-hub", "cauchy-condensation-test-hub"]
- term-by-term-estimates-hub: ...
- cauchy-condensation-test-hub: ...
"""


PROMPT_TEMPLATE_REASONING = """You are tagging a Lean theorem with which "knowledge hubs" from an analysis-strategy taxonomy are relevant to proving it. Each hub represents a strategy family (e.g., "term-by-term estimates", "Cauchy condensation test").

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE:
{signature_block}

The full hub catalogue (22 hubs total, with strategies):

{hub_block}

TASK: think through how you would prove this theorem before listing hubs.

STEP 1 — Analyze the problem. What is being claimed? What objects appear (sums, integrals, sequences, measures, etc.)? What is the mathematical structure?

STEP 2 — Sketch a proof plan. What is the most natural strategy? What lemmas or techniques would you use? What sub-goals would you split it into?

STEP 3 — Match your plan to the hub catalogue. For each hub, ask: would the strategies in this hub appear in my proof? If yes, include the hub. Be selective — typical answers are 2-6 hubs.

STEP 4 — Output your final JSON array of hub IDs on a single line, then a one-sentence justification per hub.

Write your STEP 1, 2, 3 reasoning openly, then the final JSON array. Example for STEP 4:
["term-by-term-estimates-hub", "cauchy-condensation-test-hub"]
- term-by-term-estimates-hub: ...
- cauchy-condensation-test-hub: ...
"""


# Match any JSON array (empty or list of strings).
JSON_ARRAY_RE = re.compile(r"\[\s*(?:\"[^\"]*\"(?:\s*,\s*\"[^\"]*\")*)?\s*\]", re.DOTALL)


def extract_hub_array(text: str) -> tuple[list[str], bool]:
    """Pull the first JSON-array of strings out of free text.

    Returns (hubs, parsed_ok). `parsed_ok` distinguishes an explicit empty
    array (model said "none apply") from a parse failure.
    """
    if not text:
        return [], False
    m = JSON_ARRAY_RE.search(text)
    if not m:
        return [], False
    raw = m.group(0)
    try:
        arr = json.loads(raw)
        if isinstance(arr, list):
            return ([str(x).strip() for x in arr if isinstance(x, str)], True)
    except json.JSONDecodeError:
        pass
    return [], False


def safe_slot(pid: str, model: str) -> str:
    return "HR_" + hashlib.md5(f"{pid}|{model}".encode()).hexdigest()[:10]


def cell_dir(model: str, pid: str) -> Path:
    return EVAL_DIR / model.replace("/", "_") / pid


def prf(predicted: list[str], truth: list[str]) -> dict:
    p_set = set(predicted)
    t_set = set(truth)
    tp = len(p_set & t_set)
    fp = len(p_set - t_set)
    fn = len(t_set - p_set)
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    f1 = (2 * precision * recall / (precision + recall)) if (precision + recall) else 0.0
    return {
        "tp": tp, "fp": fp, "fn": fn,
        "precision": round(precision, 4),
        "recall": round(recall, 4),
        "f1": round(f1, 4),
        "predicted": sorted(p_set),
        "truth": sorted(t_set),
    }


async def run_one(sem: asyncio.Semaphore, problem: dict, model: str,
                   hubs: list[dict], wall_s: int, prompt_mode: str = "direct") -> dict:
    async with sem:
        pid = problem["problem_id"]
        cdir = cell_dir(model, pid)
        result_path = cdir / "result.json"
        if result_path.exists():
            try:
                rec = json.loads(result_path.read_text(encoding="utf-8"))
                rec["skipped"] = True
                return rec
            except Exception:
                pass
        cdir.mkdir(parents=True, exist_ok=True)

        if prompt_mode == "proof":
            tmpl = PROMPT_TEMPLATE_PROOF
        elif prompt_mode == "reasoning":
            tmpl = PROMPT_TEMPLATE_REASONING
        else:
            tmpl = PROMPT_TEMPLATE
        fmt_kwargs = dict(
            statement_en=problem.get("statement_en", "(missing)"),
            signature_block=problem.get("verified_signature", "(missing)"),
            final_proof=problem.get("final_proof", "(missing)"),
            hub_block=render_hub_block(hubs),
        )
        prompt = tmpl.format(**fmt_kwargs)
        (cdir / "prompt.txt").write_text(prompt, encoding="utf-8")

        cmd = [CODEX_BIN, "exec", "-m", model, "--skip-git-repo-check", prompt]
        env = os.environ.copy()

        t0 = time.time()
        wall_exceeded = False
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            env=env,
        )
        try:
            stdout, stderr = await asyncio.wait_for(
                proc.communicate(), timeout=wall_s,
            )
        except asyncio.TimeoutError:
            wall_exceeded = True
            try:
                proc.kill()
            except ProcessLookupError:
                pass
            try:
                stdout, stderr = await proc.communicate()
            except Exception:
                stdout, stderr = b"", b""
        wall = round(time.time() - t0, 2)
        out_text = (stdout or b"").decode("utf-8", errors="replace")
        err_text = (stderr or b"").decode("utf-8", errors="replace")
        (cdir / "response.txt").write_text(out_text, encoding="utf-8")
        if err_text:
            (cdir / "stderr.txt").write_text(err_text, encoding="utf-8")

        predicted, parsed_ok = extract_hub_array(out_text)
        truth = problem.get("ground_truth_hubs") or []
        m = prf(predicted, truth)

        record = {
            "problem_id": pid,
            "model": model,
            "wall_seconds": wall,
            "wall_exceeded": wall_exceeded,
            "parsed_ok": parsed_ok,
            "predicted": predicted,
            "truth": truth,
            **m,
        }
        result_path.write_text(json.dumps(record, indent=2, ensure_ascii=False), encoding="utf-8")
        return record


async def run_all(manifest: dict, model: str, hubs: list[dict],
                   wall_s: int, parallel: int, prompt_mode: str = "direct") -> list[dict]:
    sem = asyncio.Semaphore(parallel)
    tasks = [run_one(sem, p, model, hubs, wall_s, prompt_mode) for p in manifest["problems"]]
    total = len(tasks)
    print(f"Hub-recall: {total} problems, model={model}, parallel={parallel}", flush=True)
    results = []
    completed = 0
    for fut in asyncio.as_completed(tasks):
        r = await fut
        completed += 1
        if r.get("skipped"):
            print(f"[{completed}/{total}] SKIP {r['problem_id']}", flush=True)
        else:
            print(f"[{completed}/{total}] {r['problem_id']:<32s}  P={r['precision']:.2f} R={r['recall']:.2f} F1={r['f1']:.2f}  pred={len(r['predicted'])} truth={len(r['truth'])}  wall={r['wall_seconds']}s",
                  flush=True)
        results.append(r)
    return results


def aggregate(results: list[dict]) -> dict:
    if not results:
        return {"n": 0}
    p = sum(r["precision"] for r in results) / len(results)
    rr = sum(r["recall"] for r in results) / len(results)
    f = sum(r["f1"] for r in results) / len(results)
    micro_tp = sum(r["tp"] for r in results)
    micro_fp = sum(r["fp"] for r in results)
    micro_fn = sum(r["fn"] for r in results)
    mp = micro_tp / (micro_tp + micro_fp) if (micro_tp + micro_fp) else 0.0
    mr = micro_tp / (micro_tp + micro_fn) if (micro_tp + micro_fn) else 0.0
    mf1 = (2 * mp * mr / (mp + mr)) if (mp + mr) else 0.0
    return {
        "n": len(results),
        "macro": {"precision": round(p, 4), "recall": round(rr, 4), "f1": round(f, 4)},
        "micro": {
            "precision": round(mp, 4), "recall": round(mr, 4), "f1": round(mf1, 4),
            "tp": micro_tp, "fp": micro_fp, "fn": micro_fn,
        },
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--wall", type=int, default=DEFAULT_WALL_S)
    ap.add_argument("--parallel", type=int, default=DEFAULT_PARALLEL)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--prompt-mode", choices=["direct", "reasoning", "proof"], default="direct")
    ap.add_argument("--eval-dir", default=None,
                    help="override output dir (default: eval_overnight_opencode/hub_recall)")
    args = ap.parse_args()

    if args.eval_dir:
        global EVAL_DIR
        EVAL_DIR = Path(args.eval_dir)

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    if args.limit:
        manifest["problems"] = manifest["problems"][:args.limit]
    hubs = load_hubs()
    print(f"Loaded {len(hubs)} hubs. Prompt mode: {args.prompt_mode}.")

    EVAL_DIR.mkdir(parents=True, exist_ok=True)
    results = asyncio.run(run_all(manifest, args.model, hubs, args.wall, args.parallel,
                                  args.prompt_mode))
    agg = aggregate(results)
    out = EVAL_DIR / args.model.replace("/", "_") / "aggregate.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({"aggregate": agg, "results": results}, indent=2,
                              ensure_ascii=False), encoding="utf-8")
    print(f"\nMacro P/R/F1: {agg['macro']['precision']:.2f}/{agg['macro']['recall']:.2f}/{agg['macro']['f1']:.2f}")
    print(f"Micro P/R/F1: {agg['micro']['precision']:.2f}/{agg['micro']['recall']:.2f}/{agg['micro']['f1']:.2f}")
    print(f"Written to {out}")


if __name__ == "__main__":
    main()
