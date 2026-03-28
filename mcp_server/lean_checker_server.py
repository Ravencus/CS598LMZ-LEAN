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


@mcp.tool()
def check_lean_proof(code: str) -> str:
    """Check Lean 4 code and return compiler diagnostics.

    Write the COMPLETE Lean 4 source file content including all imports.
    Returns JSON with 'success' (bool) and 'diagnostics' (list of errors/warnings).
    """
    _ensure_src_dir()
    scratch_file = os.path.join(SRC_DIR, "Check.lean")

    with open(scratch_file, "w") as f:
        f.write(code)

    try:
        result = subprocess.run(
            ["lake", "env", "lean", scratch_file],
            cwd=LAKE_PROJECT,
            capture_output=True,
            text=True,
            timeout=120,
        )

        # Lean may output diagnostics to either stdout or stderr
        combined = result.stdout + "\n" + result.stderr
        diagnostics = _parse_diagnostics(combined)
        errors = [d for d in diagnostics if d["severity"] == "error"]

        output = {
            "success": len(errors) == 0 and result.returncode == 0,
            "exit_code": result.returncode,
            "diagnostics": diagnostics,
        }

        return json.dumps(output, indent=2)

    except subprocess.TimeoutExpired:
        return json.dumps({
            "success": False,
            "exit_code": -1,
            "diagnostics": [
                {
                    "severity": "error",
                    "message": "Lean check timed out after 120 seconds",
                }
            ],
        })


if __name__ == "__main__":
    mcp.run()
