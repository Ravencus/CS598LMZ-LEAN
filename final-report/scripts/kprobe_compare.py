#!/usr/bin/env python3
"""Compare K=3 (original) vs K=20 (K-probe) on gpt-5.5 and gpt-5.4-mini.

Reads:
  data/eval_overnight_opencode/<model>/<cond>/<pid>/outcome.json   (K=3)
  data/eval_kprobe_K20/<model>/<cond>/<pid>/outcome.json           (K=20)

Writes:
  report-artifacts/tables/kprobe.tex
  prints a human-readable diff to stdout
"""
from __future__ import annotations

import json
from pathlib import Path

REPO = Path('/home/raven/Desktop/lean')
K3 = REPO / 'final-report' / 'data' / 'eval_overnight_opencode'
K20 = REPO / 'final-report' / 'data' / 'eval_kprobe_K20'
TAB = REPO / 'final-report' / 'report-artifacts' / 'tables'

MODELS = ['gpt-5.5', 'gpt-5.4-mini']
CONDS = ['lean_only', 'with_sympy']
PASS = {'lean_proof', 'sympy_rescue'}

DISPLAY = {'gpt-5.5': 'gpt-5.5', 'gpt-5.4-mini': 'gpt-5.4-mini'}


def load_cells(eval_dir: Path, model: str, cond: str) -> dict[str, dict]:
    out: dict[str, dict] = {}
    d = eval_dir / model / cond
    if not d.exists():
        return out
    for pid_dir in d.iterdir():
        if not pid_dir.is_dir():
            continue
        oc_path = pid_dir / 'outcome.json'
        if not oc_path.exists():
            continue
        out[pid_dir.name] = json.loads(oc_path.read_text())
    return out


def main():
    rows = []
    converted_examples: list[tuple[str, str, str, str, str]] = []
    print(f"{'model':<14} {'cond':<12} {'K=3 pass':>10} {'K=20 pass':>10} {'Δ':>6}")
    print('-' * 60)
    for model in MODELS:
        for cond in CONDS:
            c3 = load_cells(K3, model, cond)
            c20 = load_cells(K20, model, cond)
            n = len(c3)
            pass3 = sum(1 for v in c3.values() if v.get('outcome') in PASS)
            pass20 = sum(1 for pid, v in c20.items() if v.get('outcome') in PASS)
            delta = pass20 - pass3
            rows.append((model, cond, pass3, pass20, n, delta))
            print(f'{model:<14} {cond:<12} {pass3:>5}/{n:<4} {pass20:>5}/{n:<4} {delta:>+6}')
            for pid in sorted(c3):
                if c3[pid].get('outcome') not in PASS and c20.get(pid, {}).get('outcome') in PASS:
                    converted_examples.append(
                        (model, cond, pid, c3[pid].get('outcome', '?'), c20[pid].get('outcome', '?'))
                    )

    print()
    print(f'Cells that converted at K=20 ({len(converted_examples)} total):')
    for m, c, pid, o3, o20 in converted_examples:
        print(f'  {m}/{c}/{pid}  [{o3} -> {o20}]')

    TAB.mkdir(parents=True, exist_ok=True)
    lines = [
        r'\begin{table}[!t]',
        r'  \caption{Pass-rate change when the per-cell MCP check-call budget is raised from 10 to 20. Cells passing at the budget of 10 were not rerun. Same 30-problem sample, same 10-minute wall budget.}',
        r'  \label{tab:kprobe}',
        r'  \small',
        r'  \begin{tabular}{llcc}',
        r'    \toprule',
        r'    Model & Cond & passes (B=10 $\to$ 20) & $\Delta$ \\',
        r'    \midrule',
    ]
    for model, cond, p3, p20, n, delta in rows:
        sign = '+' if delta > 0 else ''
        lines.append(
            f"    {DISPLAY[model]} & \\texttt{{{cond.replace('_', '\\_')}}} "
            f"& {p3} $\\to$ {p20}~/~{n} "
            f"& {sign}{delta} \\\\"
        )
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table}']
    out = TAB / 'kprobe.tex'
    out.write_text('\n'.join(lines) + '\n')
    print(f'\nwrote {out}')


if __name__ == '__main__':
    main()
