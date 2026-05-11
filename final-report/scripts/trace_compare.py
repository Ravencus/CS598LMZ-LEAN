#!/usr/bin/env python3
"""Phase D: post-hoc big-vs-small reasoning trace analysis.

For each (problem, condition) where the bigger sibling passed and the smaller
sibling failed, bundle both cells' MCP submissions + final-text into a single
prompt and ask Codex to classify the failure mode:

    different_plan          : the two models pursued fundamentally different
                              proof strategies (decomposition).
    same_plan_lean_impl_diff: roughly the same plan, but the smaller model's
                              Lean code (tactics, lemma names, syntax) didn't
                              type-check.
    same_plan_search_diff   : same plan, but the smaller model couldn't find
                              the right Mathlib lemma/argument shape.
    unclear                 : insufficient evidence to classify.

Pairs:
    big = gpt-5.5            ; small = gpt-5.4-mini
    big = deepseek-v4-pro    ; small = deepseek-v4-flash

Output: data/eval_overnight_opencode/trace_compare/{vendor}/<pid>__<cond>/result.json
        data/eval_overnight_opencode/trace_compare/aggregate.json
"""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import time
from collections import Counter, defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
EVAL_DIR = REPO_ROOT / "final-report" / "data" / "eval_overnight_opencode"
OUT_DIR = EVAL_DIR / "trace_compare"
CODEX_BIN = "codex"

VENDOR_PAIRS = [
    ("openai", "gpt-5.5", "gpt-5.4-mini"),
    ("deepseek", "deepseek-v4-pro", "deepseek-v4-flash"),
]

DEFAULT_WALL_S = 180
DEFAULT_PARALLEL = 6
DEFAULT_MODEL = "gpt-5.5"
LABELS = (
    "different_plan",
    "same_plan_lean_impl_diff",
    "same_plan_search_diff",
    "unclear",
)


def cell_dir(model: str, condition: str, pid: str) -> Path:
    return EVAL_DIR / model.replace("/", "_") / condition / pid


def load_outcome(model: str, condition: str, pid: str) -> dict | None:
    p = cell_dir(model, condition, pid) / "outcome.json"
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def extract_tool_submissions(stream_path: Path, max_calls: int = 10,
                              max_code_chars: int = 1200) -> list[dict]:
    """Walk stream.jsonl and return a compact list of MCP submissions."""
    if not stream_path.exists():
        return []
    out: list[dict] = []
    for line in stream_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        if ev.get("type") != "tool_use":
            continue
        part = ev.get("part", {}) or {}
        tool = part.get("tool", "") or ""
        if "lean-checker" not in tool and "check_lean_proof" not in tool:
            continue
        state = part.get("state", {}) or {}
        inp = state.get("input", {}) or {}
        code = inp.get("code") if isinstance(inp, dict) else None
        out_payload = state.get("output", "") or ""
        success = None
        try:
            obj = json.loads(out_payload) if out_payload else {}
            if isinstance(obj, dict):
                success = obj.get("success")
        except json.JSONDecodeError:
            pass
        out.append({
            "code": (code or "")[:max_code_chars],
            "success": success,
        })
        if len(out) >= max_calls:
            break
    return out


def render_trace(label: str, outcome_rec: dict, cell_path: Path) -> str:
    final_text_path = cell_path / "final_text.txt"
    final_text = (final_text_path.read_text(encoding="utf-8")[:1200]
                   if final_text_path.exists() else "(no final text)")
    submissions = extract_tool_submissions(cell_path / "stream.jsonl")
    parts = [
        f"=== {label} ===",
        f"model: {outcome_rec['model']}    outcome: {outcome_rec['outcome']}    "
        f"wall={outcome_rec['wall_seconds']}s    mcp_calls={outcome_rec['mcp_calls']}",
    ]
    for i, s in enumerate(submissions, 1):
        ok = "✓" if s.get("success") else "✗"
        parts.append(f"--- mcp call {i} ({ok}) ---")
        parts.append(s["code"])
    parts.append("--- final_text ---")
    parts.append(final_text)
    return "\n".join(parts)


PROMPT_TEMPLATE = """You are analyzing two Lean theorem-proving traces from the same problem. The "BIG" model succeeded; the "SMALL" model failed. Classify the failure mode.

Problem id: {pid}    Condition: {condition}

{big_block}

{small_block}

Output STRICTLY a JSON object on a single line, then 2-3 sentences of justification:

{{"label": "different_plan" | "same_plan_lean_impl_diff" | "same_plan_search_diff" | "unclear",
  "evidence": "1-2 sentences pointing to specific parts of the traces"}}

LABEL DEFINITIONS:
  different_plan          : The two models pursued substantively different decompositions (e.g., one used induction, the other used a continuous estimate).
  same_plan_lean_impl_diff: Both pursued the same plan; the small model's failure was at the Lean tactic / type-checking level (wrong tactic, type mismatch, syntax).
  same_plan_search_diff   : Same plan; the small model couldn't find the correct Mathlib lemma name or applicability.
  unclear                 : Cannot tell from the visible evidence.

Output the JSON object first, then the justification.
"""

JSON_OBJ_RE = re.compile(r"\{\s*\"label\"\s*:\s*\"([^\"]+)\"[^}]*\}", re.DOTALL)


def extract_label(text: str) -> tuple[str | None, str]:
    if not text:
        return None, ""
    m = JSON_OBJ_RE.search(text)
    if not m:
        return None, text[:200]
    try:
        obj = json.loads(m.group(0))
        label = obj.get("label")
        if label in LABELS:
            return label, obj.get("evidence", "")[:300]
    except json.JSONDecodeError:
        pass
    return None, text[:200]


def find_pairs(passing_outcomes: list[str], failing_outcomes: list[str]) -> list[dict]:
    pairs: list[dict] = []
    for vendor, big, small in VENDOR_PAIRS:
        big_dir = EVAL_DIR / big
        if not big_dir.exists():
            continue
        for cond_dir in sorted(big_dir.iterdir()):
            if not cond_dir.is_dir():
                continue
            cond = cond_dir.name
            for pid_dir in sorted(cond_dir.iterdir()):
                if not pid_dir.is_dir():
                    continue
                pid = pid_dir.name
                big_oc = load_outcome(big, cond, pid)
                small_oc = load_outcome(small, cond, pid)
                if not big_oc or not small_oc:
                    continue
                if (big_oc["outcome"] in passing_outcomes
                        and small_oc["outcome"] in failing_outcomes):
                    pairs.append({
                        "vendor": vendor,
                        "big": big, "small": small,
                        "condition": cond, "problem_id": pid,
                        "big_outcome": big_oc, "small_outcome": small_oc,
                    })
    return pairs


async def classify_pair(sem: asyncio.Semaphore, pair: dict, model: str,
                         wall_s: int) -> dict:
    async with sem:
        out_cell = (OUT_DIR / pair["vendor"]
                     / f"{pair['problem_id']}__{pair['condition']}")
        result_path = out_cell / "result.json"
        if result_path.exists():
            try:
                rec = json.loads(result_path.read_text(encoding="utf-8"))
                rec["skipped"] = True
                return rec
            except Exception:
                pass
        out_cell.mkdir(parents=True, exist_ok=True)

        big_block = render_trace(
            "BIG (passed)", pair["big_outcome"],
            cell_dir(pair["big"], pair["condition"], pair["problem_id"]),
        )
        small_block = render_trace(
            "SMALL (failed)", pair["small_outcome"],
            cell_dir(pair["small"], pair["condition"], pair["problem_id"]),
        )
        prompt = PROMPT_TEMPLATE.format(
            pid=pair["problem_id"], condition=pair["condition"],
            big_block=big_block, small_block=small_block,
        )
        (out_cell / "prompt.txt").write_text(prompt, encoding="utf-8")

        cmd = [CODEX_BIN, "exec", "-m", model, "--skip-git-repo-check", prompt]
        env = os.environ.copy()
        t0 = time.time()
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
        (out_cell / "response.txt").write_text(out_text, encoding="utf-8")

        label, evidence = extract_label(out_text)
        rec = {
            "vendor": pair["vendor"],
            "big": pair["big"], "small": pair["small"],
            "condition": pair["condition"],
            "problem_id": pair["problem_id"],
            "big_outcome": pair["big_outcome"]["outcome"],
            "small_outcome": pair["small_outcome"]["outcome"],
            "label": label,
            "evidence": evidence,
            "wall_seconds": wall,
        }
        result_path.write_text(json.dumps(rec, indent=2, ensure_ascii=False),
                               encoding="utf-8")
        return rec


async def run_all(pairs: list[dict], model: str, wall_s: int,
                   parallel: int) -> list[dict]:
    sem = asyncio.Semaphore(parallel)
    tasks = [classify_pair(sem, p, model, wall_s) for p in pairs]
    total = len(tasks)
    print(f"Classifying {total} big-vs-small pairs (parallel={parallel})", flush=True)
    out = []
    for i, fut in enumerate(asyncio.as_completed(tasks), 1):
        r = await fut
        if r.get("skipped"):
            print(f"[{i}/{total}] SKIP {r['vendor']}/{r['problem_id']}/{r['condition']}",
                  flush=True)
        else:
            print(f"[{i}/{total}] {r['vendor']:>8s}/{r['condition']:>10s}/{r['problem_id']:<32s} "
                  f"label={r['label']!s:<28s} wall={r['wall_seconds']}s",
                  flush=True)
        out.append(r)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default=DEFAULT_MODEL,
                    help="judge model for classification")
    ap.add_argument("--wall", type=int, default=DEFAULT_WALL_S)
    ap.add_argument("--parallel", type=int, default=DEFAULT_PARALLEL)
    ap.add_argument("--pass-set", nargs="+",
                    default=["lean_proof", "sympy_rescue"])
    ap.add_argument("--fail-set", nargs="+",
                    default=["compile_fail", "wall_budget_exceeded",
                              "no_final_proof", "instruction_violation"])
    args = ap.parse_args()

    pairs = find_pairs(args.pass_set, args.fail_set)
    print(f"Found {len(pairs)} big-pass / small-fail pairs.")
    by_vendor = defaultdict(int)
    for p in pairs:
        by_vendor[p["vendor"]] += 1
    for v, n in by_vendor.items():
        print(f"  {v}: {n} pairs")
    if not pairs:
        return
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    results = asyncio.run(run_all(pairs, args.model, args.wall, args.parallel))

    # Aggregate
    counts = Counter(r["label"] for r in results)
    by_vendor_label: dict[str, Counter] = defaultdict(Counter)
    for r in results:
        by_vendor_label[r["vendor"]][r["label"]] += 1

    agg = {
        "n_pairs": len(results),
        "label_counts": dict(counts),
        "by_vendor": {v: dict(c) for v, c in by_vendor_label.items()},
        "results": results,
    }
    (OUT_DIR / "aggregate.json").write_text(
        json.dumps(agg, indent=2, ensure_ascii=False), encoding="utf-8",
    )
    print("\n=== Failure-mode breakdown ===")
    for label in (*LABELS, None):
        n = counts.get(label, 0)
        if n:
            pct = (n / len(results) * 100) if results else 0
            print(f"  {str(label):<28s} {n:>3d}  ({pct:.0f}%)")
    print(f"\nWritten to {OUT_DIR / 'aggregate.json'}")


if __name__ == "__main__":
    main()
