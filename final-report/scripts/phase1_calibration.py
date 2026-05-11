"""
Phase 1 §1.6 calibration: run the 5 candidate problems through 2 models with K=3.

Goal: confirm the picks distinguish strong (gpt-5.5) vs weak (gpt-5.4-mini).
Output: per-(problem, model) pass/fail grid plus attempts-to-success.

Sympy-skill is enabled for all calls (so computational picks can emit blocks).
"""

from __future__ import annotations

import hashlib
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unified_harness import (
    NO_TOOLS_PREAMBLE,
    PROMPT_INITIAL,
    PROMPT_RETRY,
    SYMPY_SKILL_BLOCK,
    extract_sympy_blocks,
    has_bare_sorry,
    lean_compile,
    run_attempt,
    strip_codeblock,
    verify_sympy_block,
)

PICKS_FILE = Path("/workspace/final-report/data/phase1_smoke/tonight_5.json")
OUT_DIR = Path("/workspace/final-report/data/phase1_calibration")
OUT_DIR.mkdir(parents=True, exist_ok=True)

import os as _os
_default_models = "gpt-5.4-mini,gpt-5.5,claude-opus-4-7,deepseek-v4-pro,deepseek-v4-flash"
MODELS = _os.environ.get("CAL_MODELS", _default_models).split(",")
K = 3


def safe_slot(pid: str, model: str) -> str:
    return "P1Cal_" + hashlib.md5(f"{pid}|{model}".encode()).hexdigest()[:10]


def format_diagnostics_for_prompt(diags: list[dict]) -> str:
    if not diags:
        return "(no diagnostics returned)"
    return "\n".join(
        f"line {d.get('line')}:{d.get('column')}: "
        f"{d.get('severity')}: {(d.get('message') or '')[:300]}"
        for d in diags[:8]
    )


def evaluate_attempt(code: str, slot: str, response_text: str) -> dict:
    """Evaluate one attempt and assign an outcome on the success ladder.

    Outcome classes (mutually exclusive, in priority order):
      - "lean_proof"         : Lean compiles + no sorry/admit/axiom
      - "sympy_rescue"       : sympy block emitted, verified, AND code uses sorry
      - "instruction_violation" : code has bare sorry/admit/axiom but NO sympy rescue
      - "compile_fail"       : Lean has real errors (not sorry-related), no sympy rescue
    """
    compile_result = lean_compile(code, slot)
    n_errors = len(compile_result.get("errors_only", []))
    first_err = (compile_result["errors_only"][0]["message"][:200]
                 if compile_result.get("errors_only") else None)

    sympy_blocks = extract_sympy_blocks(response_text)
    sympy_witnesses = []
    if sympy_blocks:
        for b in sympy_blocks:
            v = verify_sympy_block(b)
            sympy_witnesses.append({"block": b, "verifier": v})
    sympy_emitted = len(sympy_blocks) > 0
    sympy_ok = any(w["verifier"].get("correct") for w in sympy_witnesses)

    # Detect bare sorry/admit/axiom in submitted code (outside comments).
    sorry_flags = has_bare_sorry(code)
    has_any_sorry_like = sorry_flags["any"]

    # Lean compile status (raw, before our sorry-policy)
    lean_compiles_raw = compile_result["success"]

    # Outcome classification
    if lean_compiles_raw and not has_any_sorry_like:
        outcome = "lean_proof"
        instruction_violation = False
    elif has_any_sorry_like and sympy_ok:
        # Sympy rescue: model legitimately used sympy-skill (sorry + verified block).
        outcome = "sympy_rescue"
        instruction_violation = False
    elif has_any_sorry_like:
        # Bare sorry/admit/axiom without sympy rescue → instruction violation.
        outcome = "instruction_violation"
        instruction_violation = True
    else:
        outcome = "compile_fail"
        instruction_violation = False

    return {
        "outcome": outcome,
        "overall_success": outcome in ("lean_proof", "sympy_rescue"),
        "lean_compiles_raw": lean_compiles_raw,
        "has_bare_sorry": sorry_flags["sorry"],
        "has_admit": sorry_flags["admit"],
        "has_axiom": sorry_flags["axiom"],
        "instruction_violation": instruction_violation,
        "sympy_emitted": sympy_emitted,
        "sympy_verified": sympy_ok,
        "n_errors": n_errors,
        "first_error": first_err,
        "sympy_witnesses": sympy_witnesses,
    }


def run_one_cell(pick: dict, model: str) -> dict:
    """One (problem, model) cell with K=3 retry. Sympy-skill enabled in prompt."""
    pid = pick["problem_id"]
    statement_en = pick["statement_en"]
    signature_block = pick["verified_signature"]
    slot = safe_slot(pid, model)
    cell_dir = OUT_DIR / model.replace("/", "_") / pid
    cell_dir.mkdir(parents=True, exist_ok=True)

    attempts = []
    last_code = None
    last_errors = None
    overall = False
    why_success = None
    t0 = time.time()

    for k in range(1, K + 1):
        if k == 1:
            prompt = PROMPT_INITIAL.format(
                statement_en=statement_en,
                signature_block=signature_block,
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill=SYMPY_SKILL_BLOCK,
            )
        else:
            prompt = PROMPT_RETRY.format(
                prev_code=last_code,
                diagnostics=format_diagnostics_for_prompt(last_errors or []),
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill=SYMPY_SKILL_BLOCK,
            )

        result = run_attempt(model, prompt)
        if not result.get("ok") or not result.get("response_text"):
            attempts.append({"attempt": k, "model_failed": True})
            break
        text = result["response_text"]
        code = strip_codeblock(text)
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()

        (cell_dir / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (cell_dir / f"attempt_{k}_raw.txt").write_text(text, encoding="utf-8")

        ev = evaluate_attempt(code, slot, text)
        (cell_dir / f"attempt_{k}_eval.json").write_text(
            json.dumps(ev, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        attempts.append({
            "attempt": k,
            "wall_seconds": result.get("wall_seconds"),
            **{k_: ev[k_] for k_ in ["outcome", "overall_success", "lean_compiles_raw",
                                      "has_bare_sorry", "has_admit", "has_axiom",
                                      "instruction_violation", "sympy_emitted",
                                      "sympy_verified", "n_errors", "first_error"]},
        })

        last_code = code
        # Reuse the compile result we already have from evaluate_attempt to feed retry diagnostics
        last_errors = lean_compile(code, slot).get("errors_only")

        if ev["overall_success"]:
            overall = True
            why_success = ev["outcome"]  # "lean_proof" or "sympy_rescue"
            break

    cell_summary = {
        "problem_id": pid,
        "model": model,
        "K": K,
        "overall_success": overall,
        "why_success": why_success,
        "attempts_used": len(attempts),
        "wall_seconds": round(time.time() - t0, 1),
        "attempts": attempts,
    }
    (cell_dir / "summary.json").write_text(json.dumps(cell_summary, indent=2, ensure_ascii=False), encoding="utf-8")
    return cell_summary


def main():
    picks = json.loads(PICKS_FILE.read_text())
    print(f"Calibration: {len(picks)} picks × {len(MODELS)} models × K={K}")
    print()

    # Parallelize cells (4 workers — modest)
    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {}
        for pick in picks:
            for model in MODELS:
                futures[ex.submit(run_one_cell, pick, model)] = (pick["problem_id"], model)
        results = []
        for fut in as_completed(futures):
            pid, model = futures[fut]
            try:
                r = fut.result()
                results.append(r)
                ch = "✓" if r["overall_success"] else "✗"
                why = f" via {r['why_success']}" if r["why_success"] else ""
                print(f"  [{ch}] {pid:<32} {model:<18} attempts={r['attempts_used']} wall={r['wall_seconds']}s{why}")
            except Exception as e:
                print(f"  [ERR] {pid} {model}: {e}")

    # Aggregate matrix
    def cell_label(r):
        if r is None: return "ERR"
        ch = "✓" if r["overall_success"] else "✗"
        # Look at last attempt's outcome for the cell label
        last = r["attempts"][-1] if r["attempts"] else {}
        outcome = last.get("outcome", "?")
        # Mark instruction_violation across any attempt
        any_iv = any(a.get("instruction_violation") for a in r["attempts"])
        iv_mark = " ⚠IV" if any_iv else ""
        return f"{ch} {outcome[:10]} {r['attempts_used']}a{iv_mark}"

    print()
    print("=== CALIBRATION MATRIX (outcome, attempts; ⚠IV = instruction-violation along the way) ===")
    print(f"{'problem':<32} | {' | '.join(f'{m:<22}' for m in MODELS)}")
    print("-" * 80)
    for pick in picks:
        pid = pick["problem_id"]
        cells = []
        for m in MODELS:
            r = next((rr for rr in results if rr["problem_id"] == pid and rr["model"] == m), None)
            cells.append(cell_label(r))
        print(f"{pid:<32} | {' | '.join(f'{c:<22}' for c in cells)}")

    # Summarize outcome breakdown
    print()
    print("=== OUTCOME BREAKDOWN ===")
    for m in MODELS:
        from collections import Counter
        outcomes = Counter()
        ivs = 0
        for r in results:
            if r["model"] != m: continue
            for a in r["attempts"]:
                outcomes[a.get("outcome", "?")] += 1
                if a.get("instruction_violation"): ivs += 1
        print(f"  {m}: {dict(outcomes)}  (instruction-violations: {ivs})")

    (OUT_DIR / "calibration_summary.json").write_text(
        json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print()
    print(f"Artifacts: {OUT_DIR}")


if __name__ == "__main__":
    main()
