"""
Test gpt-5.4-mini on the harmonic-sequence-diverges problem with a K=10 retry loop.

Same prompt structure as Stage 7's formalize_problem (initial + retry-with-diagnostics)
but the task is FULL PROOF (not statement-only), and K=10 (not K=3).

Saves per-attempt artifacts to data/weak_baseline/example-122-divergence-of-the-harmonic-sequence/
"""

import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
OUT_DIR = ROOT / "data" / "weak_baseline" / "example-122-divergence-of-the-harmonic-sequence"
DOCKER = Path("/workspace/docker")
SCRATCH = DOCKER / "Scratch"

OUT_DIR.mkdir(parents=True, exist_ok=True)

PROBLEM_ID = "example-122-divergence-of-the-harmonic-sequence"
WEAK_MODEL = "gpt-5.4-mini"
K = 10

STATEMENT_EN = (
    "Define the harmonic sequence $$H_n:=\\sum_{k\\leq n}\\frac{1}{k}.$$ "
    "Prove that this sequence diverges."
)

SIGNATURE_BLOCK = """import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by"""


PROMPT_INITIAL = """You are formalizing a real proof in Lean 4 + Mathlib. Replace `sorry` in the
following theorem with a complete proof. The proof must compile cleanly under
`lake env lean` with zero errors.

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE (use VERBATIM — do NOT change the def, the theorem name,
hypotheses, or conclusion):
{signature_block}
  sorry

Notation: `ℕ`/`ℤ`/`ℚ`/`ℝ`, `Finset.sum`, `Finset.range`, `Finset.Icc`,
`Filter.Tendsto`, `Filter.atTop`, `nhds`. The sum syntax in current Mathlib4 is
`∑ k ∈ Finset.range n, ...` (NOT `∑ k in ...`).

Tactics: `intro`, `rcases`, `obtain`, `have`, `calc`, `simp`, `simp_rw`,
`ring`, `linarith`, `nlinarith`, `gcongr`, `positivity`, `field_simp`, `omega`,
`norm_num`, `funext`, `rw`, `exact`, `induction ... with | zero => ... | succ n ih => ...`,
`push_cast`.

Rules:
  - Do NOT use `sorry`, `admit`, or `axiom`.
  - Do NOT invent Mathlib lemma names. Prefer tactics over guessed names.
  - Output a complete Lean 4 file (the def + theorem with proof). First line
    must be `import Mathlib`. The signature must match byte-for-byte.

Output ONLY the Lean code. NO markdown fences. NO commentary.
"""


PROMPT_RETRY = """The Lean code below failed to type-check. Fix the proof so it compiles cleanly.

Failing code:
{prev_code}

Compiler diagnostics (top errors):
{diagnostics}

Common fixes:
  - Sum syntax in modern Mathlib4 is `∑ k ∈ Finset.range n, ...` (NOT `∑ k in ...`).
  - Use `funext` to turn a pointwise equality `∀ n, f n = g n` into a function
    equality `f = g`, then `rw` works on un-applied function references.
  - Use `Finset.sum_Icc_succ_top` to peel the top term from `∑ k ∈ Icc 1 (n+1)`.
  - Use `Finset.sum_range_succ` to peel the top term from `∑ k ∈ range (n+1)`.
  - The harmonic divergence lemma in Mathlib is named
    `Real.tendsto_sum_range_one_div_nat_succ_atTop` (range form).
  - Use `not_tendsto_nhds_of_tendsto_atTop` to derive contradiction between
    a Tendsto-atTop and a Tendsto-(nhds l).
  - Universe / coercion issues: add `(↑n : ℝ)` or use `push_cast`.
  - Output a complete corrected file: import Mathlib + def + theorem + proof.

Output ONLY the corrected Lean code. NO markdown fences. NO commentary.
"""


def codex_exec(prompt: str, model: str, timeout: int = 240) -> str | None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        out_file = f.name
    try:
        r = subprocess.run(
            ["codex", "exec", "-c", f'model="{model}"', "-o", out_file, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if r.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding="utf-8").strip()
        return None
    except subprocess.TimeoutExpired:
        return None
    finally:
        try: os.unlink(out_file)
        except Exception: pass


def strip_codeblock(text: str) -> str:
    text = (text or "").strip()
    m = re.search(r"```(?:lean(?:4)?)?\s*\n(.*?)\n```", text, re.DOTALL)
    if m:
        return m.group(1).strip()
    return text


def parse_diagnostics(combined: str) -> list[dict]:
    diags = []
    cur = None
    diag_re = re.compile(r"(.+?):(\d+):(\d+):\s+(error|warning|info)(?:\([^)]+\))?:\s*(.*)")
    for line in combined.splitlines():
        m = diag_re.match(line)
        if m:
            if cur: diags.append(cur)
            cur = {"file": m.group(1), "line": int(m.group(2)), "column": int(m.group(3)),
                   "severity": m.group(4), "message": m.group(5)}
        elif cur:
            cur["message"] += "\n" + line
    if cur: diags.append(cur)
    return diags


def lean_compile(code: str, slot: str) -> dict:
    lean_file = SCRATCH / f"{slot}.lean"
    lean_file.write_text(code, encoding="utf-8")
    env = os.environ.copy()
    env["PATH"] = f"{os.path.expanduser('~')}/.elan/bin:" + env.get("PATH", "")
    try:
        r = subprocess.run(
            ["lake", "env", "lean", str(lean_file)],
            cwd=str(DOCKER), capture_output=True, text=True, timeout=180, env=env,
        )
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        diags = parse_diagnostics(combined)
        errors = [d for d in diags if d["severity"] == "error"]
        return {
            "success": len(errors) == 0,
            "exit_code": r.returncode,
            "diagnostics": diags,
            "errors_only": errors,
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "exit_code": -1, "diagnostics": [], "errors_only": [{"message": "timeout"}]}


def format_diagnostics(diags: list[dict]) -> str:
    if not diags: return "(no diagnostics)"
    return "\n".join(
        f"line {d.get('line')}:{d.get('column')}: {d.get('severity')}: {d.get('message')[:300]}"
        for d in diags[:8]
    )


def main():
    slot = "WeakHarmonic_" + hashlib.md5(PROBLEM_ID.encode()).hexdigest()[:8]
    attempts = []
    last_code = None
    last_errors = None

    print(f"Testing weak model {WEAK_MODEL} on {PROBLEM_ID} with K={K} retry loop")
    print(f"Slot: Scratch/{slot}.lean")
    print()

    t_start = time.time()
    for k in range(1, K + 1):
        t_attempt = time.time()
        if k == 1:
            prompt = PROMPT_INITIAL.format(statement_en=STATEMENT_EN, signature_block=SIGNATURE_BLOCK)
        else:
            prompt = PROMPT_RETRY.format(prev_code=last_code, diagnostics=format_diagnostics(last_errors or []))

        print(f"  [Attempt {k}/{K}] codex_exec({WEAK_MODEL}) ...", flush=True)
        t_codex = time.time()
        response = codex_exec(prompt, WEAK_MODEL)
        codex_seconds = round(time.time() - t_codex, 1)
        if not response:
            print(f"    codex returned None (timeout or error) after {codex_seconds}s")
            attempts.append({"attempt": k, "codex_failed": True, "codex_seconds": codex_seconds})
            break

        code = strip_codeblock(response)
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()

        (OUT_DIR / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (OUT_DIR / f"attempt_{k}_codex_raw.txt").write_text(response, encoding="utf-8")

        t_compile = time.time()
        result = lean_compile(code, slot)
        compile_seconds = round(time.time() - t_compile, 1)

        log = {k_: v for k_, v in result.items()}
        (OUT_DIR / f"attempt_{k}_diagnostics.json").write_text(
            json.dumps(log, indent=2, ensure_ascii=False), encoding="utf-8"
        )

        n_errors = len(result.get("errors_only", []))
        first_err = (result["errors_only"][0]["message"][:200] if result.get("errors_only") else None)
        attempt_seconds = round(time.time() - t_attempt, 1)
        attempts.append({
            "attempt": k,
            "success": result["success"],
            "n_errors": n_errors,
            "first_error": first_err,
            "codex_seconds": codex_seconds,
            "compile_seconds": compile_seconds,
            "wall_seconds": attempt_seconds,
        })
        status = "✓" if result["success"] else "✗"
        print(f"    [{status}] codex={codex_seconds}s compile={compile_seconds}s n_errors={n_errors}")
        if first_err:
            print(f"       first error: {first_err[:160]}")

        last_code = code
        last_errors = result.get("errors_only")

        if result["success"]:
            print(f"\nSUCCESS at attempt {k}.")
            break

    wall = round(time.time() - t_start, 1)
    success_attempt = next((a["attempt"] for a in attempts if a.get("success")), None)
    summary = {
        "problem_id": PROBLEM_ID,
        "weak_model": WEAK_MODEL,
        "K": K,
        "success": success_attempt is not None,
        "success_attempt": success_attempt,
        "attempts_used": len(attempts),
        "wall_seconds": wall,
        "attempts": attempts,
        "final_code": last_code,
    }
    (OUT_DIR / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\n=== SUMMARY ===")
    print(f"Success: {summary['success']} (attempt {success_attempt})")
    print(f"Attempts used: {len(attempts)}")
    print(f"Wall: {wall}s")
    print(f"Artifacts: {OUT_DIR}")


if __name__ == "__main__":
    main()
