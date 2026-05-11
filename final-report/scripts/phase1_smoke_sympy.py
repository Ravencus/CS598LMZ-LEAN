"""
§1.7 sympy-rescue ablation: same model, same problem, sympy-skill ON vs OFF.

Demonstrates that the sympy-skill is what flips the outcome — not just "stronger model".
Holding model fixed (gpt-5.5) and toggling only the prompt's SYMPY_SKILL_BLOCK clause.

Pass criterion: B.success == True AND B.sympy_witnesses >= 1
              AND (A.success == False OR A.sympy_witnesses == 0)  # A doesn't use sympy-skill
"""

from __future__ import annotations

import hashlib
import json
import sys
import time
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

MODEL = "gpt-5.5"
K = 3
PROBLEM_ID = "_synth_integral_max_cos"
STATEMENT_EN = "Prove that the integral from 0 to 2π of max(cos u, 0) equals 2."
SIGNATURE = """import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  sorry"""

OUT_DIR = Path("/workspace/final-report/data/phase1_smoke/sympy_rescue_demo")


def safe_slot(label: str) -> str:
    return "P17_" + hashlib.md5(label.encode()).hexdigest()[:10]


def fmt_diags(diags):
    if not diags: return "(no diagnostics)"
    return "\n".join(
        f"line {d.get('line')}:{d.get('column')}: {d.get('severity')}: {(d.get('message') or '')[:300]}"
        for d in diags[:8]
    )


def evaluate(code, slot, response_text):
    """Same outcome ladder as calibration."""
    compile_result = lean_compile(code, slot)
    sympy_blocks = extract_sympy_blocks(response_text)
    sympy_witnesses = []
    for b in sympy_blocks:
        v = verify_sympy_block(b)
        sympy_witnesses.append({"block": b, "verifier": v})
    sympy_ok = any(w["verifier"].get("correct") for w in sympy_witnesses)
    sf = has_bare_sorry(code)
    has_sorry = sf["any"]
    lean_ok = compile_result["success"]

    if lean_ok and not has_sorry:
        outcome = "lean_proof"
    elif has_sorry and sympy_ok:
        outcome = "sympy_rescue"
    elif has_sorry:
        outcome = "instruction_violation"
    else:
        outcome = "compile_fail"

    return {
        "outcome": outcome,
        "overall_success": outcome in ("lean_proof", "sympy_rescue"),
        "lean_compiles_raw": lean_ok,
        "has_bare_sorry": sf["sorry"],
        "sympy_emitted": len(sympy_blocks) > 0,
        "sympy_verified": sympy_ok,
        "sympy_witnesses": sympy_witnesses,
        "errors_only": compile_result.get("errors_only", []),
        "n_errors": len(compile_result.get("errors_only", [])),
    }


def run_condition(label: str, sympy_skill: str) -> dict:
    """Run K=3 on the problem with given sympy-skill clause (empty string = no sympy-skill)."""
    out_dir = OUT_DIR / f"run_{label}"
    out_dir.mkdir(parents=True, exist_ok=True)
    slot = safe_slot(f"{PROBLEM_ID}|{label}")

    attempts = []
    last_code = None
    last_errors = None
    success = False
    why = None
    sympy_witness_count = 0
    t0 = time.time()

    for k in range(1, K + 1):
        if k == 1:
            prompt = PROMPT_INITIAL.format(
                statement_en=STATEMENT_EN,
                signature_block=SIGNATURE,
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill=sympy_skill,
            )
        else:
            prompt = PROMPT_RETRY.format(
                prev_code=last_code,
                diagnostics=fmt_diags(last_errors or []),
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill=sympy_skill,
            )

        result = run_attempt(MODEL, prompt)
        if not result.get("ok"):
            attempts.append({"attempt": k, "model_failed": True})
            break
        text = result["response_text"]
        code = strip_codeblock(text)
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()
        (out_dir / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (out_dir / f"attempt_{k}_raw.txt").write_text(text, encoding="utf-8")

        ev = evaluate(code, slot, text)
        (out_dir / f"attempt_{k}_eval.json").write_text(
            json.dumps(ev, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        attempts.append({
            "attempt": k,
            "wall_seconds": result.get("wall_seconds"),
            **{k_: ev[k_] for k_ in ["outcome", "overall_success", "lean_compiles_raw",
                                      "has_bare_sorry", "sympy_emitted", "sympy_verified",
                                      "n_errors"]},
        })
        last_code = code
        last_errors = ev["errors_only"]
        if ev["overall_success"]:
            success = True
            why = ev["outcome"]
            sympy_witness_count = sum(1 for w in ev["sympy_witnesses"] if w["verifier"].get("correct"))
            break

    summary = {
        "label": label,
        "problem_id": PROBLEM_ID,
        "model": MODEL,
        "K": K,
        "sympy_skill_enabled": bool(sympy_skill),
        "success": success,
        "why_success": why,
        "sympy_witnesses": sympy_witness_count,
        "attempts_used": len(attempts),
        "wall_seconds": round(time.time() - t0, 1),
        "attempts": attempts,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    return summary


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"§1.7 sympy-rescue ablation: {MODEL} on {PROBLEM_ID}, K={K}")
    print()

    print("--- Run A (sympy-skill OFF) ---")
    A = run_condition("A_no_sympy", sympy_skill="")
    print(f"  success={A['success']}  why={A['why_success']}  attempts={A['attempts_used']}  sympy_witnesses={A['sympy_witnesses']}  wall={A['wall_seconds']}s")
    print()

    print("--- Run B (sympy-skill ON) ---")
    B = run_condition("B_with_sympy", sympy_skill=SYMPY_SKILL_BLOCK)
    print(f"  success={B['success']}  why={B['why_success']}  attempts={B['attempts_used']}  sympy_witnesses={B['sympy_witnesses']}  wall={B['wall_seconds']}s")
    print()

    pass_criterion = (
        B["success"] is True
        and B["sympy_witnesses"] >= 1
        and (A["success"] is False or A["sympy_witnesses"] == 0)
    )
    print(f"=== ABLATION RESULT ===")
    print(f"  Run A (no sympy):  success={A['success']}, sympy_witnesses={A['sympy_witnesses']}")
    print(f"  Run B (sympy):     success={B['success']}, sympy_witnesses={B['sympy_witnesses']}")
    print(f"  PASS = {pass_criterion}")


if __name__ == "__main__":
    main()
