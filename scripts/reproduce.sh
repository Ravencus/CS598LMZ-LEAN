#!/usr/bin/env bash
# reproduce.sh — entrypoint for the eval Docker image.
#
# Usage:
#   reproduce light          # default: re-aggregate shipped run logs and regenerate figures (no API calls)
#   reproduce full           # rerun the eval from scratch (5 models × 2 conditions × 30 problems; ~8 hr, costs)
#   reproduce smoke          # quick check: 1 problem, gpt-5.5 only, lean_only condition (~$0.10)
#   reproduce bash           # drop to an interactive shell
#   reproduce login          # run codex + claude OAuth inside the container
#   reproduce <other>        # forwarded as `python3 final-report/scripts/<other>` for ad-hoc runs

set -euo pipefail

REPO=/workspace
SCRIPTS="${REPO}/final-report/scripts"
DATA="${REPO}/final-report/data"

cd "${REPO}"

# --- one-time bootstrap: link the prebuilt Mathlib cache into the bind-mounted docker/ dir ---
# unified_harness.py runs `lake env lean` with cwd=/workspace/docker. The mounted
# repo's docker/ has lakefile.lean + lean-toolchain but no .lake/. Symlink to the
# precompiled cache baked into the image so the eval does not redownload Mathlib.
if [[ ! -e "${REPO}/docker/.lake" && -d /home/lean/lean-project/.lake ]]; then
    ln -s /home/lean/lean-project/.lake "${REPO}/docker/.lake"
fi

# --- patch workspace/opencode.json for the container ---
# The shipped opencode.json hard-codes the maintainer's host paths
# (/home/raven/miniconda3/envs/lmz/bin/python, /home/raven/Desktop/lean/...).
# For smoke/full/login we overwrite it with container-correct paths, after
# backing up the original to .host.bak so the user's host clone is recoverable.
patch_opencode_json() {
    local cfg="${REPO}/workspace/opencode.json"
    [[ -f "${cfg}" ]] || return 0
    if grep -q "/home/raven\|miniconda3" "${cfg}" 2>/dev/null; then
        [[ -f "${cfg}.host.bak" ]] || cp "${cfg}" "${cfg}.host.bak"
        cat > "${cfg}" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "lean-checker": {
      "type": "local",
      "command": [
        "/home/lean/venv/bin/python",
        "/workspace/mcp_server/lean_checker_server.py"
      ],
      "environment": {
        "LAKE_PROJECT": "/workspace/docker",
        "LEAN_TIMEOUT_S": "180",
        "LEAN_CHECK_BUDGET": "{env:LEAN_CHECK_BUDGET}",
        "LEAN_SCRATCH_FILE": "{env:LEAN_SCRATCH_FILE}"
      },
      "timeout": 240000
    }
  },
  "provider": {
    "deepseek": {
      "options": {
        "apiKey": "{env:DEEPSEEK_API_KEY}",
        "timeout": 600000
      }
    },
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}",
        "timeout": 600000
      }
    }
  }
}
EOF
        echo "  [patched] /workspace/workspace/opencode.json rewritten for the container (backup at opencode.json.host.bak)"
    fi
}

# --- check opencode auth state for smoke/full ---
# OpenCode reads its auth from ~/.local/share/opencode/auth.json. To run the
# eval inside the container, the host's opencode auth dir must be mounted at
# /home/lean/.local/share/opencode (see the README §0 Quickstart).
check_opencode_auth() {
    local auth=/home/lean/.local/share/opencode/auth.json
    if [[ ! -f "${auth}" ]]; then
        echo "" >&2
        echo "  [warn] OpenCode auth file not found at ${auth}." >&2
        echo "         openai/gpt-5.5 and the other model providers will fail to resolve." >&2
        echo "         Fix: rerun this command with the host's opencode auth dir mounted:" >&2
        echo "           docker run ... -v \"\${HOME}/.local/share/opencode:/home/lean/.local/share/opencode\" ..." >&2
        echo "         Or authenticate inside the container first: docker run ... reproduce login" >&2
        echo "" >&2
    fi
}

# --- subcommand dispatch ---
mode="${1:-light}"
shift || true

case "${mode}" in
    light)
        echo ">>> Light mode: re-aggregate shipped run logs and regenerate figures (no API calls)."
        echo ""
        echo "[1/4] Aggregating per-cell outcomes → eval_overnight_opencode/aggregate.json"
        python3 "${SCRIPTS}/aggregate_opencode.py"
        echo ""
        echo "[2/4] Generating architecture figures (figure-curation, figure-harness)"
        python3 "${SCRIPTS}/architecture_figures.py" || echo "  (skipped, non-fatal)"
        echo ""
        echo "[3/4] Generating dataset overview figure"
        python3 "${SCRIPTS}/dataset_overview_figure.py" || echo "  (skipped, non-fatal)"
        echo ""
        echo "[4/4] Generating eval figures (outcome breakdown, cost pareto, hub-recall) and tables"
        python3 "${SCRIPTS}/eval_figures.py"
        echo ""
        echo ">>> Done. Outputs in ${REPO}/final-report/report-artifacts/figures/ and tables/."
        ;;

    full)
        echo ">>> Full mode: rerun the eval from scratch."
        echo "    This takes ~8 hours and costs API credits across OpenAI + Anthropic + DeepSeek."
        echo "    Verify codex and claude auth first with: docker run ... reproduce login"
        echo ""
        patch_opencode_json
        check_opencode_auth
        echo ""
        echo "[1/5] Running the proving eval (5 models × 2 conditions × 30 problems)"
        python3 "${SCRIPTS}/opencode_runner.py" \
            --models deepseek-v4-flash deepseek-v4-pro gpt-5.4-mini gpt-5.5 claude-opus-4-7 \
            "$@"
        echo ""
        echo "[2/5] Capability decomposition (within-vendor pairs)"
        python3 "${SCRIPTS}/trace_compare.py"
        echo ""
        echo "[3/5] Cross-vendor (gpt-5.5 vs claude-opus-4-7) trace comparison"
        python3 "${SCRIPTS}/trace_compare_55_vs_opus.py"
        echo ""
        echo "[4/5] Hub-strategy classification (signature-only + proof-conditioned)"
        python3 "${SCRIPTS}/hub_recall_runner.py" --prompt-mode direct
        python3 "${SCRIPTS}/hub_recall_runner.py" \
            --manifest "${DATA}/manifest_faithful_proof.json" \
            --prompt-mode proof \
            --eval-dir "${DATA}/eval_overnight_opencode/hub_recall_proof"
        echo ""
        echo "[5/5] Aggregating + regenerating figures"
        python3 "${SCRIPTS}/aggregate_opencode.py"
        python3 "${SCRIPTS}/eval_figures.py"
        echo ""
        echo ">>> Done. Headline aggregate in eval_overnight_opencode/aggregate.json."
        ;;

    smoke)
        echo ">>> Smoke mode: 1 problem, gpt-5.5, lean_only (~\$0.10, ~2 min)."
        echo "    Verifies the eval pipeline wires up end-to-end."
        echo "    Verify codex auth first with: docker run ... reproduce login"
        echo ""
        patch_opencode_json
        check_opencode_auth
        echo ""
        python3 "${SCRIPTS}/opencode_runner.py" \
            --models gpt-5.5 \
            --conditions lean_only \
            --limit 1 \
            --eval-dir "${DATA}/eval_smoke" \
            "$@"
        echo ""
        echo ">>> Smoke done. Inspect ${DATA}/eval_smoke/ for per-cell outcome.json."
        ;;

    login)
        echo ">>> Running codex + claude OAuth login inside the container."
        echo "    Each CLI will print a device-code URL; open it on your host browser to authorize."
        echo "    Auth state persists to ~/.codex and ~/.claude (mount these dirs to keep auth across runs)."
        echo ""
        codex login
        echo ""
        claude /login || true
        echo ""
        echo ">>> Done. You can now run 'reproduce full' or 'reproduce smoke'."
        ;;

    bash|shell|sh)
        exec /bin/bash "$@"
        ;;

    -h|--help|help)
        sed -n '2,15p' "$0"
        ;;

    *)
        echo "Unknown mode: '${mode}'. Run 'reproduce help' for usage." >&2
        exit 2
        ;;
esac
