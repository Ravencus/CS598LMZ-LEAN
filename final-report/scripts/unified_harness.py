"""
Unified harness for the multi-model prover leaderboard.

Two backends, identical outer protocol:
  - codex_call: Codex CLI for OpenAI gpt-* models (ChatGPT-auth agentic loop)
  - claude_call: Claude Code CLI for Anthropic Opus + DeepSeek (env-override mode)

Public surface:
  - run_attempt(model_label, prompt) -> dict
  - extract_sympy_blocks(text) -> list[dict]
  - verify_sympy_block(d) -> dict
  - parse_diagnostics, lean_compile, strip_codeblock (re-exported from Stage 7 patterns)
  - PROMPT_INITIAL, PROMPT_RETRY, SYMPY_SKILL_BLOCK templates
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

DEEPSEEK_KEY_FILE = Path("/workspace/.deepseek_api")
DOCKER = Path("/workspace/docker")
SCRATCH = DOCKER / "Scratch"

CODEX_MODELS = {"gpt-5.5", "gpt-5.4-mini"}
CLAUDE_OPUS_MODELS = {"claude-opus-4-7"}
DEEPSEEK_MODELS = {"deepseek-v4-pro", "deepseek-v4-flash"}

ALL_MODELS = CODEX_MODELS | CLAUDE_OPUS_MODELS | DEEPSEEK_MODELS


# ------------------------------ Backends ------------------------------


# Run subprocesses from a neutral directory so neither CLI auto-discovers
# project context (CLAUDE.md / AGENTS.md / etc.). Keeps Codex and Claude
# on equal footing w.r.t. project-level agent instructions.
NEUTRAL_CWD = "/tmp"


def codex_call(model: str, prompt: str, timeout: int = 240) -> tuple[str | None, dict]:
    """Codex CLI agentic call. Run from /tmp so no AGENTS.md is auto-loaded."""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        out_file = f.name
    meta = {"backend": "codex", "model": model, "timed_out": False, "error": None}
    t0 = time.time()
    try:
        r = subprocess.run(
            [
                "codex", "exec",
                "--skip-git-repo-check",
                "-c", f'model="{model}"',
                "-o", out_file,
                prompt,
            ],
            capture_output=True, text=True, timeout=timeout, cwd=NEUTRAL_CWD,
        )
        meta["wall_seconds"] = round(time.time() - t0, 2)
        if r.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding="utf-8").strip(), meta
        meta["error"] = (r.stderr or "")[-500:]
        return None, meta
    except subprocess.TimeoutExpired:
        meta["wall_seconds"] = round(time.time() - t0, 2)
        meta["timed_out"] = True
        return None, meta
    finally:
        try: os.unlink(out_file)
        except Exception: pass


CLAUDE_EMPTY_MCP = Path(__file__).parent / "_minimal_claude" / "empty_mcp.json"
CLAUDE_MINIMAL_SYSTEM_PROMPT = (
    "You are a Lean 4 + Mathlib expert. Output Lean 4 code as instructed. "
    "Do not invoke tools. Do not add commentary outside what the user asks for."
)


def claude_call(model: str, prompt: str, deepseek_mode: bool = False, timeout: int = 240) -> tuple[str | None, dict]:
    """Claude Code CLI call — minimal/headless config.

    Speed controls (each shown to matter via --output-format stream-json profiling):
      - --strict-mcp-config + empty mcp-config: prevent MCP servers (Google Drive,
        Calendar, Gmail) from loading. Default config loads ~3 servers in
        "needs-auth" status and burns time on each call.
      - --system-prompt <minimal>: replace the default agentic system prompt
        (~6,000 cached tokens) with a one-liner. Drops cache_creation_input_tokens
        from ~5,900 to ~0. 10× cost reduction, 5× wall-time reduction on PONG.
      - --tools "": disable agentic tool use (Read/Bash). The user prompt is
        self-contained; Claude must not try to explore /tmp.
      - --no-session-persistence: don't write session files to disk.
      - --disable-slash-commands: strip Claude's skill registry (already in
        place; matches Codex's no-skill posture).
      - --dangerously-skip-permissions: suppress any latent confirmation prompts
        that might block headless calls.
      - cwd=/tmp: prevent CLAUDE.md auto-discovery.

    For DeepSeek (deepseek_mode=True), redirect to DeepSeek's Anthropic-compat
    endpoint. We set both ANTHROPIC_AUTH_TOKEN and ANTHROPIC_API_KEY so any auth
    path the CLI tries succeeds.

    Reasoning budget: we DROP --effort max. The original reason for it (DeepSeek-V4
    needs reasoning headroom) is mitigated by removing the 6k-token system prompt;
    the model now has plenty of effective budget within the 240s wall.
    """
    meta = {"backend": "claude", "model": model, "deepseek_mode": deepseek_mode, "timed_out": False, "error": None}

    env = os.environ.copy()
    if deepseek_mode:
        if not DEEPSEEK_KEY_FILE.exists():
            meta["error"] = f"DeepSeek key file missing: {DEEPSEEK_KEY_FILE}"
            return None, meta
        ds_key = DEEPSEEK_KEY_FILE.read_text().strip()
        env["ANTHROPIC_BASE_URL"] = "https://api.deepseek.com/anthropic"
        env["ANTHROPIC_AUTH_TOKEN"] = ds_key
        env["ANTHROPIC_API_KEY"] = ds_key

    cmd = [
        "claude", "--print",
        "--strict-mcp-config", "--mcp-config", str(CLAUDE_EMPTY_MCP),
        "--system-prompt", CLAUDE_MINIMAL_SYSTEM_PROMPT,
        "--disable-slash-commands",
        "--tools", "",
        "--no-session-persistence",
        "--dangerously-skip-permissions",
        "--model", model,
        "-p", prompt,
    ]

    t0 = time.time()
    try:
        r = subprocess.run(
            cmd,
            capture_output=True, text=True, timeout=timeout, env=env, cwd=NEUTRAL_CWD,
        )
        meta["wall_seconds"] = round(time.time() - t0, 2)
        if r.returncode == 0:
            return (r.stdout or "").strip(), meta
        meta["error"] = (r.stderr or "")[-500:]
        return None, meta
    except subprocess.TimeoutExpired:
        meta["wall_seconds"] = round(time.time() - t0, 2)
        meta["timed_out"] = True
        return None, meta


# ------------------------------ Dispatch ------------------------------


def run_attempt(model_label: str, prompt: str, timeout: int = 240) -> dict:
    """Single LLM call with uniform output schema."""
    if model_label not in ALL_MODELS:
        raise ValueError(f"Unknown model_label: {model_label}. Known: {sorted(ALL_MODELS)}")

    if model_label in CODEX_MODELS:
        text, meta = codex_call(model_label, prompt, timeout=timeout)
    elif model_label in CLAUDE_OPUS_MODELS:
        text, meta = claude_call(model_label, prompt, deepseek_mode=False, timeout=timeout)
    else:  # DEEPSEEK_MODELS
        text, meta = claude_call(model_label, prompt, deepseek_mode=True, timeout=timeout)

    return {
        "model": model_label,
        "response_text": text,
        "wall_seconds": meta.get("wall_seconds"),
        "ok": text is not None and len(text) > 0,
        "backend": meta.get("backend"),
        "deepseek_mode": meta.get("deepseek_mode", False),
        "timed_out": meta.get("timed_out", False),
        "error": meta.get("error"),
    }


# ------------------------------ Reused helpers (mirror Stage 7) ------------------------------


def strip_codeblock(text: str) -> str:
    text = (text or "").strip()
    m = re.search(r"```(?:lean(?:4)?)?\s*\n(.*?)\n```", text, re.DOTALL)
    return m.group(1).strip() if m else text


_DIAG_RE = re.compile(r"(.+?):(\d+):(\d+):\s+(error|warning|info)(?:\([^)]+\))?:\s*(.*)")

# Detect bare sorry/admit/axiom outside of comments. Used to flag instruction violations.
_BARE_SORRY_RE = re.compile(r"(?<!--)\b(sorry|admit)\b")
_AXIOM_RE = re.compile(r"^\s*axiom\b", re.MULTILINE)


def _strip_lean_comments(code: str) -> str:
    """Remove `-- ...` line comments and `/- ... -/` block comments before scanning."""
    # Block comments (non-greedy; nesting is rare in our outputs)
    code = re.sub(r"/-.*?-/", "", code, flags=re.DOTALL)
    # Line comments
    code = re.sub(r"--[^\n]*", "", code)
    return code


def has_bare_sorry(code: str) -> dict:
    """Detect sorry/admit/axiom in non-comment Lean code.

    Returns: {"sorry": bool, "admit": bool, "axiom": bool, "any": bool}
    """
    cleaned = _strip_lean_comments(code or "")
    sorry = bool(re.search(r"\bsorry\b", cleaned))
    admit = bool(re.search(r"\badmit\b", cleaned))
    axiom = bool(_AXIOM_RE.search(cleaned))
    return {"sorry": sorry, "admit": admit, "axiom": axiom, "any": sorry or admit or axiom}


def parse_diagnostics(combined: str) -> list[dict]:
    diags = []
    cur = None
    for line in combined.splitlines():
        m = _DIAG_RE.match(line)
        if m:
            if cur: diags.append(cur)
            cur = {
                "file": m.group(1), "line": int(m.group(2)), "column": int(m.group(3)),
                "severity": m.group(4), "message": m.group(5),
            }
        elif cur:
            cur["message"] += "\n" + line
    if cur: diags.append(cur)
    return diags


def lean_compile(code: str, slot: str) -> dict:
    """Write code to Scratch/<slot>.lean and run lake env lean."""
    SCRATCH.mkdir(parents=True, exist_ok=True)
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
        return {
            "success": False, "exit_code": -1,
            "diagnostics": [{"severity": "error", "message": "lake env lean timed out"}],
            "errors_only": [{"severity": "error", "message": "timeout"}],
        }


# ------------------------------ Sympy-skill ------------------------------


SYMPY_SKILL_BLOCK = """SYMPY-SKILL: If a sub-claim within the proof is a definite integral, finite
sum with a known closed form, or a numeric identity that you cannot easily
prove in Lean, you may delegate the verification by emitting a single block
of the form:
  <sympy>
  {
    "kind": "integral",
    "var": "u",
    "lower": "0",
    "upper": "2*pi",
    "expression": "Max(cos(u), 0)",
    "expected": "2"
  }
  </sympy>
"kind" is one of: "integral", "sum", "equality", "limit".
External verification will accept the corresponding sorry if sympy confirms
the claim. Emit at most one block per attempt. Use sympy syntax (Max(...),
not \\max), not LaTeX."""


_SYMPY_BLOCK_RE = re.compile(r"<sympy>\s*(\{.*?\})\s*</sympy>", re.DOTALL)


def extract_sympy_blocks(text: str) -> list[dict]:
    """Return parsed JSON from <sympy>...</sympy> blocks. Skip malformed silently."""
    if not text:
        return []
    out = []
    for m in _SYMPY_BLOCK_RE.finditer(text):
        raw = m.group(1).strip()
        # strip JS-style // comments that some models include
        cleaned = re.sub(r"//[^\n]*", "", raw)
        try:
            d = json.loads(cleaned)
            if isinstance(d, dict):
                out.append(d)
        except json.JSONDecodeError:
            pass
    return out


def verify_sympy_block(block: dict) -> dict:
    """Wrap sympy_verifier per block kind. Returns {correct, computed, error}."""
    sys.path.insert(0, "/workspace/final-artifacts/scripts")
    try:
        from sympy_verifier import (
            verify_integral as _vi,
            verify_equality as _ve,
            verify_limit as _vl,
        )
    except Exception as e:
        return {"correct": False, "computed": None, "error": f"import_failed: {e}"}

    kind = block.get("kind", "").lower()
    try:
        if kind == "integral":
            r = _vi(
                integrand_str=block.get("expression", ""),
                var_str=block.get("var", "x"),
                lower_str=str(block.get("lower", "")),
                upper_str=str(block.get("upper", "")),
                expected_str=str(block.get("expected", "")),
            )
        elif kind == "equality":
            r = _ve(
                lhs_str=block.get("lhs", block.get("expression", "")),
                rhs_str=str(block.get("expected", "")),
            )
        elif kind == "limit":
            r = _vl(
                expr_str=block.get("expression", ""),
                var_str=block.get("var", "x"),
                point_str=str(block.get("point", "0")),
                expected_str=str(block.get("expected", "")),
            )
        elif kind == "sum":
            # sum_str = block.get("expression", "")
            return {"correct": False, "computed": None, "error": "sum kind not yet implemented"}
        else:
            return {"correct": False, "computed": None, "error": f"unknown kind: {kind}"}
        return {
            "correct": bool(r.correct),
            "computed": r.computed_result,
            "error": r.error,
        }
    except Exception as e:
        return {"correct": False, "computed": None, "error": f"verify_failed: {type(e).__name__}: {e}"}


# ------------------------------ Prompt templates ------------------------------


NO_TOOLS_PREAMBLE = """You have no Lean compiler, shell, file editor, or external tools available
during this turn. Output one complete Lean 4 file as your final answer; the
compiler will verify it externally and you will receive its errors on the
next round if it does not compile.
"""


PROMPT_INITIAL = """You are formalizing a real proof in Lean 4 + Mathlib. Replace `sorry` in the
following theorem with a complete proof. The proof must compile cleanly under
`lake env lean` with zero errors.

{no_tools_preamble}

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE (use VERBATIM — do NOT change name, hypotheses, or conclusion):
{signature_block}

Notation: `ℕ`/`ℤ`/`ℚ`/`ℝ`/`ℂ`, `Finset.sum`, `Filter.Tendsto`, `Filter.atTop`,
`nhds`, `Real.pi`, `Summable`, etc. Sum syntax: `∑ k ∈ Finset.range n, ...`
(NOT `∑ k in ...`).

Tactics: `intro`, `rcases`, `obtain`, `have`, `calc`, `simp`, `ring`,
`linarith`, `nlinarith`, `gcongr`, `positivity`, `field_simp`, `omega`,
`norm_num`, `funext`, `rw`, `exact`, `induction`, `push_cast`.

Rules:
  - Do NOT use `sorry`, `admit`, or `axiom` (unless using SYMPY-SKILL below).
  - Do NOT invent Mathlib lemma names. Prefer tactics over guessed names.
  - Output a complete Lean 4 file (import + def + theorem + proof).
  - First line must be `import Mathlib`. The signature must match byte-for-byte.

{sympy_skill}

Output ONLY the Lean code (and at most one <sympy>...</sympy> block if needed).
NO markdown fences. NO commentary."""


PROMPT_RETRY = """The Lean code below failed to type-check. Fix the proof so it compiles cleanly.

{no_tools_preamble}

Failing code:
{prev_code}

Compiler diagnostics (top errors):
{diagnostics}

Common fixes:
  - `∑ k in S, ...` is no longer valid; use `∑ k ∈ S, ...`.
  - Use `funext` to turn `∀ n, f n = g n` into `f = g`, then `rw` works on un-applied functions.
  - Use `Finset.sum_Icc_succ_top` to peel from `∑ k ∈ Icc 1 (n+1)`.
  - Use `Finset.sum_range_succ` to peel from `∑ k ∈ range (n+1)`.
  - The harmonic divergence lemma in Mathlib is `Real.tendsto_sum_range_one_div_nat_succ_atTop`.
  - Use `not_tendsto_nhds_of_tendsto_atTop` for atTop-vs-nhds contradictions.
  - Coercion issues: use `push_cast`.

{sympy_skill}

Output ONLY corrected Lean code. NO markdown fences. NO commentary."""


# ------------------------------ Self-test ------------------------------


def _self_test():
    print("Self-test: PONG-ping all 5 models through unified harness...")
    print()
    for m in ["gpt-5.5", "gpt-5.4-mini", "deepseek-v4-pro", "deepseek-v4-flash", "claude-opus-4-7"]:
        r = run_attempt(m, "Reply with exactly: PONG")
        text = (r.get("response_text") or "")
        ok = "PONG" in text.upper()
        print(f"  {m:<22} ok={ok}  wall={r.get('wall_seconds')}s  text={text[:30]!r}")


if __name__ == "__main__":
    _self_test()
