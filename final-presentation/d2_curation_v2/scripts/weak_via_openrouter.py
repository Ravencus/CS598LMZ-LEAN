"""
Weak baseline: gpt-5.4-mini via OpenRouter, single-shot per round + K=10 retry loop
with lake compile diagnostic feedback. Same problem as the manual strong baseline:
example-122-divergence-of-the-harmonic-sequence.

Pure Python loop. No agentic harness. Each round = one OpenAI-compatible chat call,
one lake compile, diagnostic-feedback prompt for the next round.

Usage:
  OPENROUTER_API_KEY=$(cat /tmp/openrouter_key.txt) python3 weak_via_openrouter.py
"""

import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

from openai import OpenAI

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
OUT_DIR = ROOT / "data" / "weak_baseline" / "example-122-divergence-of-the-harmonic-sequence"
DOCKER = Path("/workspace/docker")
SCRATCH = DOCKER / "Scratch"

OUT_DIR.mkdir(parents=True, exist_ok=True)

PROBLEM_ID = "example-122-divergence-of-the-harmonic-sequence"
MODEL = os.environ.get("WEAK_MODEL", "openai/gpt-5.4-mini")
K = int(os.environ.get("K", "10"))
MAX_TOKENS = int(os.environ.get("MAX_TOKENS", "4000"))

STATEMENT_EN = (
    "Define the harmonic sequence H_n := sum_{k=1}^{n} 1/k. "
    "Prove that this sequence diverges (i.e., does not converge to any real l)."
)

SIGNATURE_BLOCK = """import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by"""


PROMPT_INITIAL = """You are formalizing a real proof in Lean 4 + Mathlib. Replace `sorry` with a complete proof. The proof must compile cleanly under `lake env lean` with zero errors.

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE (use VERBATIM — do NOT change the def, the theorem name, hypotheses, or conclusion):
{signature_block}
  sorry

Notation in Mathlib4: ℕ, ℤ, ℚ, ℝ, Finset.sum, Finset.range, Finset.Icc, Filter.Tendsto, Filter.atTop, nhds. The sum syntax is `∑ k ∈ Finset.range n, ...` (NOT `∑ k in ...`).

Tactics: intro, rcases, obtain, have, calc, simp, simp_rw, ring, linarith, nlinarith, gcongr, positivity, field_simp, omega, norm_num, funext, rw, exact, induction, push_cast.

Rules:
  - Do NOT use sorry, admit, or axiom.
  - Do NOT invent Mathlib lemma names.
  - Output a complete Lean 4 file: import Mathlib + open Filter + the def + the theorem with proof. First line must be `import Mathlib`. Signature must match byte-for-byte.

Output ONLY Lean code. NO markdown fences. NO commentary."""


PROMPT_RETRY = """The Lean code below failed to type-check. Fix the proof so it compiles cleanly.

Failing code:
{prev_code}

Compiler diagnostics (top errors):
{diagnostics}

Common fixes:
  - Sum syntax in Mathlib4 is `∑ k ∈ Finset.range n, ...` (NOT `∑ k in ...`).
  - Use `funext` to turn `∀ n, f n = g n` into `f = g`, then `rw` works on un-applied function references.
  - Use `Finset.sum_Icc_succ_top` to peel the top term from `∑ k ∈ Icc 1 (n+1)`.
  - Use `Finset.sum_range_succ` to peel the top term from `∑ k ∈ range (n+1)`.
  - The harmonic divergence lemma in Mathlib is `Real.tendsto_sum_range_one_div_nat_succ_atTop`.
  - Use `not_tendsto_nhds_of_tendsto_atTop` to derive contradiction.
  - Coercion issues: use `push_cast`.
  - Output a complete corrected file: import Mathlib + open Filter + def + theorem + proof.

Output ONLY corrected Lean code. NO markdown fences. NO commentary."""


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
        return {"success": False, "exit_code": -1, "diagnostics": [], "errors_only": [{"message": "lake timeout"}]}


def format_diagnostics(diags: list[dict]) -> str:
    if not diags: return "(no diagnostics)"
    return "\n".join(
        f"line {d.get('line')}:{d.get('column')}: {d.get('severity')}: {d.get('message')[:300]}"
        for d in diags[:8]
    )


def main():
    api_key = os.environ.get("OPENROUTER_API_KEY") or open("/tmp/openrouter_key.txt").read().strip()
    if not api_key:
        print("No OpenRouter key found", file=sys.stderr); sys.exit(1)

    client = OpenAI(api_key=api_key, base_url="https://openrouter.ai/api/v1")
    slot = "WeakHarmonicOR_" + hashlib.md5(PROBLEM_ID.encode()).hexdigest()[:8]

    print(f"Model: {MODEL} (via OpenRouter)")
    print(f"Problem: {PROBLEM_ID}")
    print(f"K: {K}")
    print(f"Slot: Scratch/{slot}.lean")
    print()

    attempts = []
    last_code = None
    last_errors = None

    t_start = time.time()
    for k in range(1, K + 1):
        t_attempt = time.time()
        if k == 1:
            prompt = PROMPT_INITIAL.format(statement_en=STATEMENT_EN, signature_block=SIGNATURE_BLOCK)
        else:
            prompt = PROMPT_RETRY.format(prev_code=last_code, diagnostics=format_diagnostics(last_errors or []))

        print(f"  [Attempt {k}/{K}] calling {MODEL} ...", flush=True)
        t_call = time.time()
        try:
            resp = client.chat.completions.create(
                model=MODEL,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=MAX_TOKENS,
                temperature=0.0,
            )
            response_text = (resp.choices[0].message.content or "").strip()
            usage = getattr(resp, "usage", None)
            usage_dict = {"prompt_tokens": getattr(usage, "prompt_tokens", None),
                          "completion_tokens": getattr(usage, "completion_tokens", None)} if usage else {}
        except Exception as e:
            print(f"    API call failed: {e}")
            attempts.append({"attempt": k, "api_failed": True, "error": str(e)})
            break
        call_seconds = round(time.time() - t_call, 1)

        if not response_text:
            print(f"    Empty response after {call_seconds}s")
            attempts.append({"attempt": k, "empty_response": True, "call_seconds": call_seconds})
            break

        code = strip_codeblock(response_text)
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()

        (OUT_DIR / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (OUT_DIR / f"attempt_{k}_raw.txt").write_text(response_text, encoding="utf-8")

        t_compile = time.time()
        result = lean_compile(code, slot)
        compile_seconds = round(time.time() - t_compile, 1)

        log = {kk: vv for kk, vv in result.items()}
        (OUT_DIR / f"attempt_{k}_diagnostics.json").write_text(
            json.dumps(log, indent=2, ensure_ascii=False), encoding="utf-8"
        )

        n_errors = len(result.get("errors_only", []))
        first_err = (result["errors_only"][0]["message"][:200] if result.get("errors_only") else None)
        attempt_seconds = round(time.time() - t_attempt, 1)
        attempts.append({
            "attempt": k, "success": result["success"],
            "n_errors": n_errors, "first_error": first_err,
            "call_seconds": call_seconds, "compile_seconds": compile_seconds,
            "wall_seconds": attempt_seconds, "usage": usage_dict,
        })
        status = "✓" if result["success"] else "✗"
        print(f"    [{status}] call={call_seconds}s compile={compile_seconds}s n_errors={n_errors}", flush=True)
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
        "problem_id": PROBLEM_ID, "model": MODEL, "K": K,
        "success": success_attempt is not None, "success_attempt": success_attempt,
        "attempts_used": len(attempts), "wall_seconds": wall,
        "attempts": attempts, "final_code": last_code,
    }
    (OUT_DIR / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\n=== SUMMARY ===")
    print(f"Model:         {MODEL}")
    print(f"Success:       {summary['success']} (attempt {success_attempt})")
    print(f"Attempts used: {len(attempts)}")
    print(f"Wall:          {wall}s")
    print(f"Artifacts:     {OUT_DIR}")


if __name__ == "__main__":
    main()
