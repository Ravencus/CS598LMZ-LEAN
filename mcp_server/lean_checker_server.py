import subprocess
import re
import os
import json
import tempfile
import shutil

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("Lean Proof Checker")

LAKE_PROJECT = os.environ.get("LAKE_PROJECT", "/workspace/lean_project")
SRC_DIR = os.path.join(LAKE_PROJECT, "Scratch")
SCRATCH_FILE = os.environ.get("LEAN_SCRATCH_FILE", "Check.lean")
LEAN_TIMEOUT_S = int(os.environ.get("LEAN_TIMEOUT_S", "120"))

try:
    CHECK_BUDGET = int(os.environ.get("LEAN_CHECK_BUDGET", "0"))
except ValueError:
    CHECK_BUDGET = 0
_check_calls = 0


def _ensure_src_dir():
    os.makedirs(SRC_DIR, exist_ok=True)


def _parse_diagnostics(stderr: str) -> list[dict]:
    diagnostics = []
    # Lean outputs multi-line errors; first line has location, rest is detail
    current = None
    for line in stderr.splitlines():
        loc_match = re.match(
            r"(.+?):(\d+):(\d+):\s+(error|warning|info):\s+(.*)", line
        )
        if loc_match:
            if current:
                diagnostics.append(current)
            current = {
                "file": loc_match.group(1),
                "line": int(loc_match.group(2)),
                "column": int(loc_match.group(3)),
                "severity": loc_match.group(4),
                "message": loc_match.group(5),
            }
        elif current:
            current["message"] += "\n" + line
    if current:
        diagnostics.append(current)
    return diagnostics


_PLACEHOLDER_RE = re.compile(r"\b(sorry|admit|axiom)\b")


def _strip_comments(src: str) -> str:
    """Remove `-- ...` line comments and `/- ... -/` block comments before scanning."""
    src = re.sub(r"/-.*?-/", "", src, flags=re.DOTALL)
    src = re.sub(r"--[^\n]*", "", src)
    return src


@mcp.tool()
def check_lean_proof(code: str) -> str:
    """Check Lean 4 code and return compiler diagnostics.

    Write the COMPLETE Lean 4 source file content including all imports.
    Returns JSON with 'success' (bool) and 'diagnostics' (list of errors/warnings).

    Enforces the FINAL-proof rule against `sorry` / `admit` / `axiom`: if any
    of those tokens appears in the submitted code (outside comments), the tool
    returns success=false with a diagnostic, so the agent receives an in-loop
    signal to keep iterating instead of treating the submission as accepted.
    """
    global _check_calls
    _check_calls += 1
    if CHECK_BUDGET > 0 and _check_calls > CHECK_BUDGET:
        return json.dumps({
            "success": False,
            "exit_code": -2,
            "budget_exhausted": True,
            "calls_used": _check_calls,
            "calls_budget": CHECK_BUDGET,
            "diagnostics": [{
                "severity": "error",
                "message": (
                    f"BUDGET_EXHAUSTED: you have used {_check_calls} of {CHECK_BUDGET} "
                    f"check_lean_proof calls. No further checker calls will be honored. "
                    f"Submit your best attempt (with `sorry` for incomplete parts) and "
                    f"report what you tried."
                ),
            }],
        }, indent=2)

    _ensure_src_dir()
    scratch_file = os.path.join(SRC_DIR, SCRATCH_FILE)

    with open(scratch_file, "w") as f:
        f.write(code)

    try:
        result = subprocess.run(
            ["lake", "env", "lean", scratch_file],
            cwd=LAKE_PROJECT,
            capture_output=True,
            text=True,
            timeout=LEAN_TIMEOUT_S,
        )

        # Lean may output diagnostics to either stdout or stderr
        combined = result.stdout + "\n" + result.stderr
        diagnostics = _parse_diagnostics(combined)
        errors = [d for d in diagnostics if d["severity"] == "error"]

        lean_ok = len(errors) == 0 and result.returncode == 0
        scrubbed = _strip_comments(code)
        placeholder_match = _PLACEHOLDER_RE.search(scrubbed)
        if placeholder_match:
            token = placeholder_match.group(1)
            diagnostics.append({
                "severity": "error",
                "message": (
                    f"FINAL_PROOF_RULE: `{token}` is not allowed in submitted "
                    f"code. Continue iterating to fill in the proof, or use "
                    f"SYMPY-SKILL (if available) to discharge the remaining "
                    f"goal. This submission is rejected."
                ),
            })
            success = False
        else:
            success = lean_ok

        output = {
            "success": success,
            "exit_code": result.returncode,
            "calls_used": _check_calls,
            "calls_budget": CHECK_BUDGET if CHECK_BUDGET > 0 else None,
            "lean_compiles": lean_ok,
            "placeholder_violation": bool(placeholder_match),
            "diagnostics": diagnostics,
        }

        return json.dumps(output, indent=2)

    except subprocess.TimeoutExpired:
        return json.dumps({
            "success": False,
            "exit_code": -1,
            "calls_used": _check_calls,
            "calls_budget": CHECK_BUDGET if CHECK_BUDGET > 0 else None,
            "diagnostics": [
                {
                    "severity": "error",
                    "message": f"Lean check timed out after {LEAN_TIMEOUT_S} seconds",
                }
            ],
        })


if __name__ == "__main__":
    mcp.run()
