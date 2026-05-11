#!/usr/bin/env python3
"""gpt-5.5 vs claude-opus-4-7 trace comparison on lean_only, all 30 problems.

For each problem in the lean_only condition, bundle both traces and ask Codex:
  - plan_relation : same_plan / different_plan / unclear
  - divergence    : lean_impl / search / instruction_following / none / n/a
  - evidence      : free text

Output: data/eval_overnight_opencode/trace_compare_55_vs_opus/<pid>/result.json
        data/eval_overnight_opencode/trace_compare_55_vs_opus/aggregate.json
"""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import time
from collections import Counter
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
EVAL_DIR = REPO_ROOT / "final-report" / "data" / "eval_overnight_opencode"
OUT_DIR = EVAL_DIR / "trace_compare_55_vs_opus"
CODEX_BIN = "codex"

MODEL_A = "gpt-5.5"
MODEL_B = "claude-opus-4-7"
CONDITION = "lean_only"

DEFAULT_WALL_S = 240
DEFAULT_PARALLEL = 6
DEFAULT_JUDGE = "gpt-5.5"

PLAN_RELATIONS = ("same_plan", "different_plan", "unclear")
DIVERGENCES = ("lean_impl", "search", "instruction_following", "none", "n/a")


def cell_dir(model: str, pid: str) -> Path:
    return EVAL_DIR / model / CONDITION / pid


def load_outcome(model: str, pid: str) -> dict | None:
    p = cell_dir(model, pid) / "outcome.json"
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def extract_tool_submissions(stream_path: Path, max_calls: int = 10,
                              max_code_chars: int = 1200) -> list[dict]:
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
        out.append({"code": (code or "")[:max_code_chars], "success": success})
        if len(out) >= max_calls:
            break
    return out


def render_trace(label: str, outcome_rec: dict, cell_path: Path) -> str:
    final_text_path = cell_path / "final_text.txt"
    final_text = (final_text_path.read_text(encoding="utf-8")[:1500]
                   if final_text_path.exists() else "(no final text)")
    submissions = extract_tool_submissions(cell_path / "stream.jsonl")
    parts = [
        f"=== {label} ===",
        f"model: {outcome_rec['model']}    outcome: {outcome_rec['outcome']}    "
        f"wall={outcome_rec['wall_seconds']}s    mcp_calls={outcome_rec['mcp_calls']}",
    ]
    for i, s in enumerate(submissions, 1):
        ok = "PASS" if s.get("success") else "FAIL"
        parts.append(f"--- mcp call {i} ({ok}) ---")
        parts.append(s["code"])
    parts.append("--- final_text ---")
    parts.append(final_text)
    return "\n".join(parts)


PROMPT_TEMPLATE = """You are analyzing two Lean theorem-proving traces from the same problem. Both ran under the same agentic harness (OpenCode + a `check_lean_proof` Lean checker tool, lean_only condition, no sympy escape). Classify the relationship between the two reasoning approaches.

Problem id: {pid}

{block_a}

{block_b}

Output STRICTLY a JSON object on a single line, then 2-3 sentences of justification:

{{"plan_relation": "same_plan" | "different_plan" | "unclear",
  "divergence": "lean_impl" | "search" | "instruction_following" | "none" | "n/a",
  "evidence": "1-2 sentences pointing to specific parts of the traces"}}

Definitions:
  plan_relation:
    same_plan       : both pursued the same overall mathematical decomposition (e.g., both used induction, both reduced to a Mathlib identity, both invoked the same lemma family).
    different_plan  : substantively different decompositions.
    unclear         : cannot determine from visible evidence (e.g., one model gave up almost immediately).
  divergence (semantically meaningful only when plan_relation == same_plan):
    lean_impl              : divergent outcomes due to Lean tactic / type-checking errors on one side.
    search                 : divergent due to inability to find the right Mathlib lemma name.
    instruction_following  : one model followed the rules and produced a proof; the other gave up by emitting `sorry` despite an explicit rule against it.
    none                   : same plan AND similar execution (e.g., both pass cleanly with the same proof shape).
    n/a                    : not applicable (use when plan_relation != same_plan).

Output the JSON object first, then the justification.
"""

JSON_OBJ_RE = re.compile(r"\{\s*\"plan_relation\"\s*:[^}]*\}", re.DOTALL)


def extract_labels(text: str) -> tuple[str | None, str | None, str]:
    if not text:
        return None, None, ""
    m = JSON_OBJ_RE.search(text)
    if not m:
        return None, None, text[:200]
    try:
        obj = json.loads(m.group(0))
    except json.JSONDecodeError:
        return None, None, text[:200]
    pr = obj.get("plan_relation")
    dv = obj.get("divergence")
    ev = (obj.get("evidence") or "")[:300]
    if pr not in PLAN_RELATIONS:
        pr = None
    if dv not in DIVERGENCES:
        dv = None
    return pr, dv, ev


def find_problems() -> list[str]:
    a_dir = EVAL_DIR / MODEL_A / CONDITION
    b_dir = EVAL_DIR / MODEL_B / CONDITION
    a_pids = {p.name for p in a_dir.iterdir() if p.is_dir()}
    b_pids = {p.name for p in b_dir.iterdir() if p.is_dir()}
    return sorted(a_pids & b_pids)


async def classify(sem: asyncio.Semaphore, pid: str, judge_model: str,
                    wall_s: int) -> dict:
    async with sem:
        out_cell = OUT_DIR / pid
        result_path = out_cell / "result.json"
        if result_path.exists():
            try:
                rec = json.loads(result_path.read_text(encoding="utf-8"))
                rec["skipped"] = True
                return rec
            except Exception:
                pass
        out_cell.mkdir(parents=True, exist_ok=True)

        oc_a = load_outcome(MODEL_A, pid)
        oc_b = load_outcome(MODEL_B, pid)
        if not (oc_a and oc_b):
            return {"problem_id": pid, "error": "missing outcome"}

        block_a = render_trace(f"TRACE A ({MODEL_A})", oc_a, cell_dir(MODEL_A, pid))
        block_b = render_trace(f"TRACE B ({MODEL_B})", oc_b, cell_dir(MODEL_B, pid))
        prompt = PROMPT_TEMPLATE.format(pid=pid, block_a=block_a, block_b=block_b)
        (out_cell / "prompt.txt").write_text(prompt, encoding="utf-8")

        cmd = [CODEX_BIN, "exec", "-m", judge_model,
               "--skip-git-repo-check", prompt]
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

        plan_relation, divergence, evidence = extract_labels(out_text)
        rec = {
            "problem_id": pid,
            "model_a": MODEL_A, "model_b": MODEL_B,
            "outcome_a": oc_a["outcome"], "outcome_b": oc_b["outcome"],
            "plan_relation": plan_relation,
            "divergence": divergence,
            "evidence": evidence,
            "wall_seconds": wall,
        }
        result_path.write_text(json.dumps(rec, indent=2, ensure_ascii=False),
                               encoding="utf-8")
        return rec


async def run_all(pids: list[str], judge: str, wall_s: int,
                   parallel: int) -> list[dict]:
    sem = asyncio.Semaphore(parallel)
    tasks = [classify(sem, p, judge, wall_s) for p in pids]
    total = len(tasks)
    print(f"Comparing {total} problems (parallel={parallel}, judge={judge})", flush=True)
    out = []
    for i, fut in enumerate(asyncio.as_completed(tasks), 1):
        r = await fut
        if r.get("skipped"):
            print(f"[{i}/{total}] SKIP {r['problem_id']}", flush=True)
        elif r.get("error"):
            print(f"[{i}/{total}] ERR  {r['problem_id']}: {r['error']}", flush=True)
        else:
            print(f"[{i}/{total}] {r['problem_id']:<48s} "
                  f"plan={r['plan_relation']!s:<16s} div={r['divergence']!s:<22s} "
                  f"a={r['outcome_a']:<22s} b={r['outcome_b']:<22s} wall={r['wall_seconds']}s",
                  flush=True)
        out.append(r)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--judge", default=DEFAULT_JUDGE)
    ap.add_argument("--wall", type=int, default=DEFAULT_WALL_S)
    ap.add_argument("--parallel", type=int, default=DEFAULT_PARALLEL)
    ap.add_argument("--limit", type=int, default=None)
    args = ap.parse_args()

    pids = find_problems()
    if args.limit:
        pids = pids[:args.limit]
    print(f"Found {len(pids)} problems with both {MODEL_A} and {MODEL_B} on {CONDITION}.")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    results = asyncio.run(run_all(pids, args.judge, args.wall, args.parallel))

    plan_counts = Counter(r.get("plan_relation") for r in results
                           if not r.get("error"))
    div_counts = Counter(r.get("divergence") for r in results
                          if not r.get("error"))
    outcome_pair_counts = Counter(
        (r.get("outcome_a"), r.get("outcome_b"))
        for r in results if not r.get("error")
    )
    agg = {
        "n_problems": len([r for r in results if not r.get("error")]),
        "model_a": MODEL_A, "model_b": MODEL_B,
        "condition": CONDITION,
        "plan_relation_counts": dict(plan_counts),
        "divergence_counts": dict(div_counts),
        "outcome_pair_counts": {f"{a}|{b}": n
                                  for (a, b), n in outcome_pair_counts.items()},
        "results": results,
    }
    (OUT_DIR / "aggregate.json").write_text(
        json.dumps(agg, indent=2, ensure_ascii=False), encoding="utf-8",
    )
    print("\n=== plan_relation counts ===")
    for k, v in plan_counts.most_common():
        print(f"  {str(k):<20s} {v}")
    print("\n=== divergence counts ===")
    for k, v in div_counts.most_common():
        print(f"  {str(k):<24s} {v}")
    print(f"\nWritten to {OUT_DIR / 'aggregate.json'}")


if __name__ == "__main__":
    main()
