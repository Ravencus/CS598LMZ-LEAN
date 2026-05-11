"""
Phase 1 §1.4 smoke test: 1 problem × 1 model × K=3.

Verifies the unified harness end-to-end: prompt build → model call → strip code →
lake compile → diagnostics → retry on failure → save artifacts.

Pass criterion: summary.json shows success: true AND at least 1 attempt_*.lean exists.
"""

from __future__ import annotations

import hashlib
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unified_harness import (
    ALL_MODELS,
    NO_TOOLS_PREAMBLE,
    PROMPT_INITIAL,
    PROMPT_RETRY,
    SYMPY_SKILL_BLOCK,
    lean_compile,
    parse_diagnostics,
    run_attempt,
    strip_codeblock,
)

PROBLEM_ID = "example-127"  # StrictMono(2*k) ∧ ∀k, id(2*k)=2*k — trivial
MODEL = "gpt-5.4-mini"
K = 3

DATASET_NODES = Path("/workspace/final-presentation/d2_curation_v2/data/dataset_v2/nodes")
FORMALIZATIONS = Path("/workspace/final-presentation/d2_curation_v2/data/formalizations")
OUT_DIR = Path("/workspace/final-report/data/phase1_smoke")


def safe_slot(pid: str) -> str:
    return "P1Smoke_" + hashlib.md5(pid.encode()).hexdigest()[:10]


def build_signature_block(stage7_final_code: str) -> str:
    """Use Stage-7 verified file as the signature block (it ends in `:= by sorry`)."""
    # Strip trailing whitespace, keep `:= by sorry` so the model knows to replace it
    return stage7_final_code.rstrip()


def format_diagnostics_for_prompt(diags: list[dict]) -> str:
    if not diags:
        return "(no diagnostics returned)"
    parts = []
    for d in diags[:8]:
        parts.append(
            f"line {d.get('line')}:{d.get('column')}: "
            f"{d.get('severity')}: {(d.get('message') or '')[:300]}"
        )
    return "\n".join(parts)


def main():
    # Load the problem
    node_path = DATASET_NODES / f"{PROBLEM_ID}.json"
    if not node_path.exists():
        print(f"ERROR: {node_path} not found")
        sys.exit(1)
    node = json.loads(node_path.read_text(encoding="utf-8"))
    statement_en = node.get("statement_en", "")

    # Load Stage-7 verified signature
    s7_path = FORMALIZATIONS / PROBLEM_ID / "summary.json"
    if not s7_path.exists():
        print(f"ERROR: {s7_path} not found")
        sys.exit(1)
    s7 = json.loads(s7_path.read_text(encoding="utf-8"))
    signature_block = build_signature_block(s7["final_code"])

    # Output dir
    out = OUT_DIR / PROBLEM_ID
    out.mkdir(parents=True, exist_ok=True)
    slot = safe_slot(PROBLEM_ID)

    print(f"Problem: {PROBLEM_ID}")
    print(f"Model:   {MODEL}")
    print(f"K:       {K}")
    print(f"Slot:    Scratch/{slot}.lean")
    print()

    attempts = []
    last_code = None
    last_errors = None
    success = False
    t_start = time.time()

    for k in range(1, K + 1):
        if k == 1:
            prompt = PROMPT_INITIAL.format(
                statement_en=statement_en,
                signature_block=signature_block,
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill="",  # disabled for plain smoke
            )
        else:
            prompt = PROMPT_RETRY.format(
                prev_code=last_code,
                diagnostics=format_diagnostics_for_prompt(last_errors or []),
                no_tools_preamble=NO_TOOLS_PREAMBLE,
                sympy_skill="",
            )

        print(f"  [Attempt {k}/{K}] calling {MODEL} ...", flush=True)
        result = run_attempt(MODEL, prompt)
        if not result.get("ok") or not result.get("response_text"):
            print(f"    [✗] model call returned no text (timed_out={result.get('timed_out')})")
            attempts.append({"attempt": k, "ok": False, "model_failed": True, **{k_: result.get(k_) for k_ in ['wall_seconds', 'timed_out', 'error']}})
            break

        code = strip_codeblock(result["response_text"])
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()

        (out / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (out / f"attempt_{k}_raw.txt").write_text(result["response_text"], encoding="utf-8")

        compile_result = lean_compile(code, slot)
        diag_record = {kk: vv for kk, vv in compile_result.items() if kk != "stderr_tail"}
        (out / f"attempt_{k}_diagnostics.json").write_text(
            json.dumps(diag_record, indent=2, ensure_ascii=False), encoding="utf-8"
        )

        n_errors = len(compile_result.get("errors_only", []))
        first_err = (compile_result["errors_only"][0]["message"][:200]
                     if compile_result.get("errors_only") else None)

        attempts.append({
            "attempt": k,
            "ok": True,
            "compile_success": compile_result["success"],
            "n_errors": n_errors,
            "first_error": first_err,
            "wall_seconds": result.get("wall_seconds"),
        })
        status = "✓" if compile_result["success"] else "✗"
        print(f"    [{status}] wall={result['wall_seconds']}s n_errors={n_errors}"
              + (f"  first_error={first_err[:80]!r}" if first_err else ""))

        last_code = code
        last_errors = compile_result.get("errors_only")

        if compile_result["success"]:
            success = True
            break

    wall = round(time.time() - t_start, 2)

    summary = {
        "problem_id": PROBLEM_ID,
        "model": MODEL,
        "K": K,
        "success": success,
        "attempts_used": len(attempts),
        "wall_seconds": wall,
        "attempts": attempts,
        "final_code": last_code,
    }
    (out / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")

    status_ch = "✓" if success else "✗"
    print()
    print(f"=== SUMMARY ===")
    print(f"  [{status_ch}] {PROBLEM_ID}  attempts={len(attempts)}  wall={wall}s  success={success}")
    print(f"  artifacts: {out}")


if __name__ == "__main__":
    main()
