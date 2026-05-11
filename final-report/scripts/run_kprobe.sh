#!/usr/bin/env bash
# K-probe: rerun gpt-5.5 + gpt-5.4-mini failures at K=20, both conditions.
# Preserves K=3 outcomes by writing to a separate eval dir.
set -euo pipefail

REPO=/home/raven/Desktop/lean
SRC=$REPO/final-report/data/eval_overnight_opencode
DST=$REPO/final-report/data/eval_kprobe_K20

echo "[1/5] Seeding $DST with K=3 outcomes for gpt-5.5 and gpt-5.4-mini..."
mkdir -p "$DST"
for model in gpt-5.5 gpt-5.4-mini; do
    for cond in lean_only with_sympy; do
        mkdir -p "$DST/$model/$cond"
        cp -r "$SRC/$model/$cond/." "$DST/$model/$cond/"
    done
done

echo "[2/5] Deleting outcome.json for failing cells so they re-run..."
python3 - <<'EOF'
import json
from pathlib import Path
SRC = Path('/home/raven/Desktop/lean/final-report/data/eval_overnight_opencode')
DST = Path('/home/raven/Desktop/lean/final-report/data/eval_kprobe_K20')
n_clear = 0
for model in ['gpt-5.5', 'gpt-5.4-mini']:
    for cond in ['lean_only', 'with_sympy']:
        for pid_dir in sorted((SRC / model / cond).iterdir()):
            if not pid_dir.is_dir():
                continue
            oc = json.loads((pid_dir / 'outcome.json').read_text())
            if oc.get('outcome') in ('lean_proof', 'sympy_rescue'):
                continue
            dst_oc = DST / model / cond / pid_dir.name / 'outcome.json'
            if dst_oc.exists():
                dst_oc.unlink()
                n_clear += 1
print(f'  cleared {n_clear} cells for re-run')
EOF

echo "[3/5] Backing up opencode.db..."
OPENCODE_STATE=$HOME/.local/share/opencode
TS=$(date +%Y%m%d_%H%M%S)
for f in opencode.db opencode.db-shm opencode.db-wal; do
    if [ -f "$OPENCODE_STATE/$f" ]; then
        mv "$OPENCODE_STATE/$f" "$OPENCODE_STATE/$f.kprobe-backup.$TS"
    fi
done
echo "  backup tag: kprobe-backup.$TS"

echo "[4/5] Launching K-probe (K=20, wall=1200s, parallel=16)..."
cd "$REPO"
python3 final-report/scripts/opencode_runner.py \
    --models gpt-5.5 gpt-5.4-mini \
    --conditions lean_only with_sympy \
    --budget 20 \
    --wall 1200 \
    --parallel 16 \
    --eval-dir "$DST"

echo "[5/5] Post-audit signature_mismatch on K-probe results..."
python3 final-report/scripts/audit_signatures.py --apply --eval-dir "$DST"

echo "Done."
