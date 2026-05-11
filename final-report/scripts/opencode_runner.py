#!/usr/bin/env python3
"""Arm B: agentic OpenCode runner over the same 30-problem manifest as Arm A.

Each cell = (problem, model, condition). One `opencode run` invocation per cell.
The model uses the `check_lean_proof` MCP tool with a hard call budget enforced
server-side. Stream JSON events are saved as `stream.jsonl`. After the agent
finishes, we extract its FINAL_PROOF block and re-compile it independently via
`lake env lean` to get ground-truth pass/fail.

Outcome ladder mirrors `overnight_runner.py` with two additions:
  - wall_budget_exceeded : orchestrator killed the cell at --wall seconds
  - no_final_proof       : agent never emitted a FINAL_PROOF block
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

SCRIPTS = Path(__file__).resolve().parent
REPO_ROOT = SCRIPTS.parent.parent

# Make sympy_verifier importable BEFORE importing unified_harness, since the
# helper inside unified_harness inserts a hardcoded /workspace path that does
# not exist on this host.
sys.path.insert(0, str(REPO_ROOT / "final-artifacts" / "scripts"))
sys.path.insert(0, str(SCRIPTS))

from unified_harness import (  # noqa: E402
    extract_sympy_blocks,
    verify_sympy_block,
    has_bare_sorry,
    parse_diagnostics,
    SYMPY_SKILL_BLOCK,
)

DOCKER = REPO_ROOT / "docker"
SCRATCH = DOCKER / "Scratch"
WORKSPACE = REPO_ROOT / "workspace"
FINAL_REPORT = REPO_ROOT / "final-report"
EVAL_DIR = FINAL_REPORT / "data" / "eval_overnight_opencode"
SNAPSHOT_DIR = FINAL_REPORT / "data" / "eval_snapshots" / "20260510_083526_partial"
DEFAULT_MANIFEST = SNAPSHOT_DIR / "manifest.json"

OPENCODE_BIN = Path.home() / ".opencode" / "bin" / "opencode"
LEAN_BIN_DIR = Path.home() / ".elan" / "bin"
DEEPSEEK_KEY_FILE = REPO_ROOT / ".deepseek_api"
ANTHROPIC_KEY_FILE = REPO_ROOT / ".opus_api"

PROVIDER_OPENAI = {"gpt-5.5", "gpt-5.4-mini"}
PROVIDER_DEEPSEEK = {"deepseek-v4-pro", "deepseek-v4-flash"}
PROVIDER_ANTHROPIC = {"claude-opus-4-7", "claude-opus-4-6", "claude-haiku-4-5"}

DEFAULT_BUDGET = 10
DEFAULT_WALL_S = 300
DEFAULT_PARALLEL = 8
LEAN_COMPILE_TIMEOUT_S = 180


_SIG_NAME_RE = re.compile(r"\b(?:theorem|lemma)\s+([A-Za-z_][A-Za-z0-9_']*)")


def extract_expected_theorem_name(signature_block: str) -> str | None:
    """Pull the theorem/lemma name out of the manifest's verified_signature."""
    if not signature_block:
        return None
    m = _SIG_NAME_RE.search(signature_block)
    return m.group(1) if m else None


def final_proves_expected(final_code: str | None, expected_name: str | None) -> bool:
    """True iff final.lean defines a `theorem`/`lemma` with the expected name.

    Submissions that compile by replacing the asked-for theorem with an `example`
    or a renamed trivial theorem (e.g. `theorem test : True := by trivial`) do
    not count as a real proof and are labelled `signature_mismatch`.
    """
    if not final_code or not expected_name:
        return expected_name is None
    pattern = re.compile(
        r"^\s*(?:noncomputable\s+)?(?:theorem|lemma)\s+"
        + re.escape(expected_name)
        + r"\b",
        re.M,
    )
    return bool(pattern.search(final_code))


def model_to_provider_arg(model: str) -> str:
    if model in PROVIDER_OPENAI:
        return f"openai/{model}"
    if model in PROVIDER_DEEPSEEK:
        return f"deepseek/{model}"
    if model in PROVIDER_ANTHROPIC:
        return f"anthropic/{model}"
    raise ValueError(f"unknown model: {model}")


PROMPT_TEMPLATE = """You are formalizing a real proof in Lean 4 + Mathlib. You have access to a `check_lean_proof` MCP tool that compiles Lean code and returns diagnostics. Use it to iterate on your proof.

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE (use VERBATIM — do NOT change name, hypotheses, or conclusion):
{signature_block}

You have a HARD BUDGET of {budget} `check_lean_proof` calls. Each call response includes `calls_used` and `calls_budget` so you can track usage. When the budget is exhausted, no further checker calls work — submit your best final attempt and stop.

Notation: `ℕ`/`ℤ`/`ℚ`/`ℝ`/`ℂ`, `Finset.sum`, `Filter.Tendsto`, `Filter.atTop`,
`nhds`, `Real.pi`, `Summable`, etc. Sum syntax: `∑ k ∈ Finset.range n, ...`
(NOT `∑ k in ...`).

Tactics: `intro`, `rcases`, `obtain`, `have`, `calc`, `simp`, `ring`,
`linarith`, `nlinarith`, `gcongr`, `positivity`, `field_simp`, `omega`,
`norm_num`, `funext`, `rw`, `exact`, `induction`, `push_cast`.

Rules:
  - Do NOT use `sorry`, `admit`, or `axiom` in the FINAL proof (unless using SYMPY-SKILL below).
  - Do NOT invent Mathlib lemma names. Prefer tactics over guessed names.
  - First line must be `import Mathlib`. The signature must match byte-for-byte.

{sympy_skill}

When you have a proof that compiles (or you've used the budget), output your FINAL answer as one fenced lean block, prefixed with the literal token `FINAL_PROOF:`. Output it exactly once, after your proof compiles or you've stopped iterating:

FINAL_PROOF:
```lean
import Mathlib
... your final code ...
```
"""

FINAL_BLOCK_RE = re.compile(
    r"FINAL_PROOF:\s*```(?:lean)?\s*(.*?)```",
    re.DOTALL | re.IGNORECASE,
)
FALLBACK_LEAN_BLOCK_RE = re.compile(r"```lean\s*(.*?)```", re.DOTALL)


def extract_final_proof(text: str) -> str | None:
    if not text:
        return None
    m = FINAL_BLOCK_RE.search(text)
    if m:
        return m.group(1).strip()
    m2 = FALLBACK_LEAN_BLOCK_RE.search(text)
    if m2:
        return m2.group(1).strip()
    return None


def lean_compile_local(code: str, slot: str) -> dict:
    SCRATCH.mkdir(parents=True, exist_ok=True)
    lean_file = SCRATCH / f"{slot}.lean"
    lean_file.write_text(code, encoding="utf-8")
    env = os.environ.copy()
    env["PATH"] = f"{LEAN_BIN_DIR}:" + env.get("PATH", "")
    try:
        r = subprocess.run(
            ["lake", "env", "lean", str(lean_file)],
            cwd=str(DOCKER), capture_output=True, text=True,
            timeout=LEAN_COMPILE_TIMEOUT_S, env=env,
        )
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        diags = parse_diagnostics(combined)
        errors = [d for d in diags if d["severity"] == "error"]
        return {"success": len(errors) == 0, "exit_code": r.returncode,
                "diagnostics": diags, "errors_only": errors}
    except subprocess.TimeoutExpired:
        return {"success": False, "exit_code": -1,
                "diagnostics": [{"severity": "error", "message": "lake timed out"}],
                "errors_only": [{"severity": "error", "message": "timeout"}]}


def safe_slot(pid: str, model: str, condition: str) -> str:
    return "P2OC_" + hashlib.md5(f"{pid}|{model}|{condition}".encode()).hexdigest()[:10]


def cell_dir(model: str, condition: str, pid: str) -> Path:
    safe_model = model.replace("/", "_")
    return EVAL_DIR / safe_model / condition / pid


def parse_stream(stdout_s: str) -> dict:
    """Walk JSON events emitted by `opencode run --format json`."""
    mcp_calls = 0
    budget_hit_event = False
    final_text_parts: list[str] = []
    last_compiled_code: str | None = None
    last_submitted_code: str | None = None
    total_cost = 0.0
    total_tokens = 0
    for line in stdout_s.splitlines():
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        t = ev.get("type")
        part = ev.get("part", {}) or {}
        if t == "tool_use":
            tool_name = part.get("tool", "") or ""
            if "lean-checker" in tool_name or "check_lean_proof" in tool_name:
                mcp_calls += 1
                state = part.get("state", {}) or {}
                inp = state.get("input", {}) or {}
                code = inp.get("code") if isinstance(inp, dict) else None
                if code:
                    last_submitted_code = code
                output = state.get("output", "") or ""
                if "BUDGET_EXHAUSTED" in output:
                    budget_hit_event = True
                else:
                    # Did this tool call compile cleanly?
                    try:
                        out_obj = json.loads(output) if output else {}
                        if (isinstance(out_obj, dict)
                                and out_obj.get("success") is True
                                and code):
                            last_compiled_code = code
                    except json.JSONDecodeError:
                        pass
        elif t == "text":
            final_text_parts.append(part.get("text", "") or "")
        elif t == "step_finish":
            cost = part.get("cost") or 0
            if isinstance(cost, (int, float)):
                total_cost += cost
            tok = part.get("tokens") or {}
            if isinstance(tok, dict):
                total_tokens += int(tok.get("total") or 0)
    return {
        "mcp_calls": mcp_calls,
        "budget_hit_event": budget_hit_event,
        "final_text": "\n".join(final_text_parts),
        "last_compiled_code": last_compiled_code,
        "last_submitted_code": last_submitted_code,
        "total_cost_usd": round(total_cost, 6),
        "total_tokens": total_tokens,
    }


async def run_cell(sem: asyncio.Semaphore, problem: dict, model: str,
                    condition: str, budget: int, wall_s: int) -> dict:
    async with sem:
        pid = problem["problem_id"]
        cdir = cell_dir(model, condition, pid)
        outcome_path = cdir / "outcome.json"
        if outcome_path.exists():
            try:
                rec = json.loads(outcome_path.read_text(encoding="utf-8"))
                rec["skipped"] = True
                return rec
            except Exception:
                pass
        cdir.mkdir(parents=True, exist_ok=True)

        slot = safe_slot(pid, model, condition)
        scratch_file = f"Check_{slot}.lean"
        sympy_block = SYMPY_SKILL_BLOCK if condition == "with_sympy" else ""
        prompt = PROMPT_TEMPLATE.format(
            statement_en=problem["statement_en"],
            signature_block=problem["verified_signature"],
            sympy_skill=sympy_block,
            budget=budget,
        )
        (cdir / "prompt.txt").write_text(prompt, encoding="utf-8")

        env = os.environ.copy()
        env["PATH"] = f"{Path.home()}/.opencode/bin:" + env.get("PATH", "")
        env["LEAN_CHECK_BUDGET"] = str(budget)
        env["LEAN_SCRATCH_FILE"] = scratch_file
        if model in PROVIDER_DEEPSEEK and DEEPSEEK_KEY_FILE.exists():
            env["DEEPSEEK_API_KEY"] = DEEPSEEK_KEY_FILE.read_text().strip()
        if model in PROVIDER_ANTHROPIC and ANTHROPIC_KEY_FILE.exists():
            env["ANTHROPIC_API_KEY"] = ANTHROPIC_KEY_FILE.read_text().strip()

        cmd = [str(OPENCODE_BIN), "run",
               "-m", model_to_provider_arg(model),
               "--format", "json",
               "--dir", str(WORKSPACE),
               prompt]

        t0 = time.time()
        wall_exceeded = False
        # Stream stdout to file as we read it so a kill doesn't lose data.
        stream_path = cdir / "stream.jsonl"
        stderr_path = cdir / "stderr.log"
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            env=env,
        )

        async def _drain(stream, path):
            chunks: list[bytes] = []
            with path.open("wb") as f:
                while True:
                    line = await stream.readline()
                    if not line:
                        break
                    f.write(line)
                    f.flush()
                    chunks.append(line)
            return b"".join(chunks)

        stdout_task = asyncio.create_task(_drain(proc.stdout, stream_path))
        stderr_task = asyncio.create_task(_drain(proc.stderr, stderr_path))
        try:
            await asyncio.wait_for(proc.wait(), timeout=wall_s)
        except asyncio.TimeoutError:
            wall_exceeded = True
            try:
                proc.kill()
            except ProcessLookupError:
                pass
            try:
                await proc.wait()
            except Exception:
                pass
        # Drain whatever remains; tasks finish when streams hit EOF.
        try:
            stdout_bytes = await asyncio.wait_for(stdout_task, timeout=10)
        except (asyncio.TimeoutError, Exception):
            stdout_task.cancel()
            stdout_bytes = b""
        try:
            stderr_bytes = await asyncio.wait_for(stderr_task, timeout=10)
        except (asyncio.TimeoutError, Exception):
            stderr_task.cancel()
            stderr_bytes = b""
        wall = round(time.time() - t0, 2)
        stdout_s = stdout_bytes.decode("utf-8", errors="replace")
        stderr_s = stderr_bytes.decode("utf-8", errors="replace")

        parsed = parse_stream(stdout_s)
        final_text = parsed["final_text"]
        (cdir / "final_text.txt").write_text(final_text, encoding="utf-8")

        # Extraction order:
        #   1. Explicit FINAL_PROOF: ```lean ...``` block from final text.
        #   2. The last check_lean_proof submission that COMPILED in-loop.
        #   3. Any fenced lean block in the final text (loose).
        #   4. The last check_lean_proof submission, even if it didn't compile.
        final_code = extract_final_proof(final_text)
        final_source = "explicit_block" if final_code else None
        if not final_code and parsed.get("last_compiled_code"):
            final_code = parsed["last_compiled_code"]
            final_source = "last_compiled_tool_call"
        if not final_code:
            m_loose = FALLBACK_LEAN_BLOCK_RE.search(final_text or "")
            if m_loose:
                final_code = m_loose.group(1).strip()
                final_source = "loose_lean_block"
        if not final_code and parsed.get("last_submitted_code"):
            final_code = parsed["last_submitted_code"]
            final_source = "last_submitted_tool_call"

        if final_code and not final_code.lstrip().startswith("import"):
            final_code = "import Mathlib\n\n" + final_code.lstrip()
        if final_code:
            (cdir / "final.lean").write_text(final_code, encoding="utf-8")

        if final_code:
            comp = lean_compile_local(final_code, slot)
        else:
            comp = {"success": False, "exit_code": -3,
                    "diagnostics": [], "errors_only": []}

        sympy_blocks = extract_sympy_blocks(final_text)
        sympy_witnesses = [
            {"block": b, "verifier": verify_sympy_block(b)} for b in sympy_blocks
        ]
        sympy_emitted = bool(sympy_blocks)
        sympy_ok = any(w["verifier"].get("correct") for w in sympy_witnesses)

        sf = has_bare_sorry(final_code or "")
        has_sorry_like = sf["any"]
        lean_ok = comp["success"]

        expected_name = extract_expected_theorem_name(
            problem.get("verified_signature", "")
        )
        signature_ok = final_proves_expected(final_code, expected_name)

        if wall_exceeded:
            outcome = "wall_budget_exceeded"
        elif final_code is None:
            outcome = "no_final_proof"
        elif lean_ok and not has_sorry_like and not signature_ok:
            outcome = "signature_mismatch"
        elif lean_ok and not has_sorry_like:
            outcome = "lean_proof"
        elif has_sorry_like and sympy_ok:
            outcome = "sympy_rescue"
        elif has_sorry_like:
            outcome = "instruction_violation"
        else:
            outcome = "compile_fail"

        record = {
            "problem_id": pid,
            "model": model,
            "condition": condition,
            "outcome": outcome,
            "overall_success": outcome in ("lean_proof", "sympy_rescue"),
            "wall_seconds": wall,
            "wall_exceeded": wall_exceeded,
            "final_proof_source": final_source,
            "mcp_calls": parsed["mcp_calls"],
            "budget": budget,
            "budget_hit_event": parsed["budget_hit_event"],
            "lean_compiles_raw": lean_ok,
            "has_bare_sorry": sf["sorry"],
            "has_admit": sf["admit"],
            "has_axiom": sf["axiom"],
            "instruction_violation": outcome == "instruction_violation",
            "expected_theorem_name": expected_name,
            "signature_ok": signature_ok,
            "sympy_emitted": sympy_emitted,
            "sympy_verified": sympy_ok,
            "n_errors": len(comp["errors_only"]),
            "first_error": (comp["errors_only"][0]["message"][:200]
                            if comp["errors_only"] else None),
            "total_cost_usd": parsed["total_cost_usd"],
            "total_tokens": parsed["total_tokens"],
            "sympy_witnesses": sympy_witnesses,
            "errors_only": comp["errors_only"],
        }
        outcome_path.write_text(
            json.dumps(record, indent=2, ensure_ascii=False), encoding="utf-8",
        )
        return record


async def run_matrix(manifest: dict, models: list[str], conditions: list[str],
                     budget: int, wall_s: int, parallel: int) -> list[dict]:
    sem = asyncio.Semaphore(parallel)
    tasks = []
    # Model-major ordering: priority by model (caller passes models in priority
    # order). The first `parallel` tasks to acquire the semaphore are the
    # highest-priority model's first cells, so the priority model finishes first.
    for model in models:
        for prob in manifest["problems"]:
            for cond in conditions:
                tasks.append(run_cell(sem, prob, model, cond, budget, wall_s))
    total = len(tasks)
    print(f"Scheduling {total} cells, parallel={parallel}", flush=True)
    results: list[dict] = []
    completed = 0
    for fut in asyncio.as_completed(tasks):
        r = await fut
        completed += 1
        if r.get("skipped"):
            print(f"[{completed}/{total}] SKIP {r['model']:>20}/{r['condition']:>10}/{r['problem_id']}",
                  flush=True)
        else:
            print(f"[{completed}/{total}] {r['outcome']:>22}  {r['model']:>20}/{r['condition']:>10}/{r['problem_id']}  "
                  f"wall={r['wall_seconds']}s mcp={r['mcp_calls']} cost=${r['total_cost_usd']}",
                  flush=True)
        results.append(r)
    return results


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    ap.add_argument("--models", nargs="+", default=None)
    ap.add_argument("--conditions", nargs="+", default=["lean_only", "with_sympy"])
    ap.add_argument("--budget", type=int, default=DEFAULT_BUDGET)
    ap.add_argument("--wall", type=int, default=DEFAULT_WALL_S)
    ap.add_argument("--parallel", type=int, default=DEFAULT_PARALLEL)
    ap.add_argument("--limit", type=int, default=None,
                    help="cap number of problems for smoke runs")
    ap.add_argument("--eval-dir", default=None,
                    help="override output directory (default: data/eval_overnight_opencode)")
    args = ap.parse_args()

    if args.eval_dir:
        global EVAL_DIR
        EVAL_DIR = Path(args.eval_dir)

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    if args.limit:
        manifest["problems"] = manifest["problems"][:args.limit]
    models = args.models or [
        "deepseek-v4-flash", "deepseek-v4-pro", "gpt-5.4-mini", "gpt-5.5",
    ]

    print(f"Models: {models}")
    print(f"Conditions: {args.conditions}")
    print(f"Problems: {len(manifest['problems'])}")
    print(f"Budget: {args.budget}, wall: {args.wall}s, parallel: {args.parallel}")

    EVAL_DIR.mkdir(parents=True, exist_ok=True)
    results = asyncio.run(run_matrix(
        manifest, models, args.conditions,
        args.budget, args.wall, args.parallel,
    ))
    (EVAL_DIR / "run_summary.jsonl").write_text(
        "\n".join(json.dumps(r, ensure_ascii=False) for r in results) + "\n",
        encoding="utf-8",
    )
    pass_count = sum(1 for r in results if r.get("overall_success"))
    print(f"\nDone. {pass_count}/{len(results)} cells passed.")


if __name__ == "__main__":
    main()
