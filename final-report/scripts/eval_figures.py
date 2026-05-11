#!/usr/bin/env python3
"""Generate evaluation figures and tables from the post-audit aggregate.

Reads:
  data/eval_overnight_opencode/aggregate.json
  data/eval_overnight_opencode/trace_compare/aggregate.json
  data/eval_overnight_opencode/trace_compare_55_vs_opus/aggregate.json
  data/eval_overnight_opencode/hub_recall/<model>/aggregate.json

Writes (PDF + PNG):
  report-artifacts/figures/outcome-breakdown.{pdf,png}
  report-artifacts/figures/cost-pareto.{pdf,png}
  report-artifacts/figures/hub-recall.{pdf,png}

Writes LaTeX snippets:
  report-artifacts/tables/main-pass-rate.tex
  report-artifacts/tables/capability-decomposition.tex
  report-artifacts/tables/runtime-cost.tex
  report-artifacts/tables/partial-opus.tex
"""
from __future__ import annotations

import json
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

matplotlib.rcParams['font.family'] = ['DejaVu Sans', 'sans-serif']
matplotlib.rcParams['figure.dpi'] = 200
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

ROOT = Path('/home/raven/Desktop/lean')
EVAL = ROOT / 'final-report' / 'data' / 'eval_overnight_opencode'
FIG = ROOT / 'final-report' / 'report-artifacts' / 'figures'
TAB = ROOT / 'final-report' / 'report-artifacts' / 'tables'
FIG.mkdir(parents=True, exist_ok=True)
TAB.mkdir(parents=True, exist_ok=True)

AGG = json.loads((EVAL / 'aggregate.json').read_text())
TC = json.loads((EVAL / 'trace_compare' / 'aggregate.json').read_text())
TC55 = json.loads((EVAL / 'trace_compare_55_vs_opus' / 'aggregate.json').read_text())

COST_MODELS = ['gpt-5.5', 'gpt-5.4-mini', 'deepseek-v4-pro', 'deepseek-v4-flash']
ALL_MODELS = COST_MODELS + ['claude-opus-4-7']
CONDS = ['lean_only', 'with_sympy']

MODEL_DISPLAY = {
    'gpt-5.5': 'gpt-5.5',
    'gpt-5.4-mini': 'gpt-5.4-mini',
    'deepseek-v4-pro': 'deepseek-pro',
    'deepseek-v4-flash': 'deepseek-flash',
    'claude-opus-4-7': 'claude-opus-4.7',
}

MERGED_GROUPS = [
    ('lean_proof', ['lean_proof'], 'lean proof', '#2ca02c'),
    ('sympy_rescue', ['sympy_rescue'], 'sympy rescue', '#98df8a'),
    ('formalization_error',
     ['compile_fail', 'signature_mismatch', 'instruction_violation'],
     'formalization error', '#d62728'),
    ('timeout',
     ['wall_budget_exceeded', 'model_timeout'],
     'timeout', '#9467bd'),
    ('no_final_proof', ['no_final_proof'], 'no final proof', '#7f7f7f'),
]


def save(fig, name):
    for ext in ('pdf', 'png'):
        p = FIG / f'{name}.{ext}'
        fig.savefig(p, bbox_inches='tight')
        print(f'  wrote {p}')


# ---------- F2 outcome breakdown ----------

def fig_outcome_breakdown():
    print('F2 outcome-breakdown:')
    fig, ax = plt.subplots(figsize=(12, 5.4))
    bar_positions = []
    labels = []
    for i, model in enumerate(ALL_MODELS):
        for cond in CONDS:
            bar_positions.append(i * 2.4 + (0 if cond == 'lean_only' else 1))
            labels.append(f"{MODEL_DISPLAY[model]}\n{cond}")
    bottoms = np.zeros(len(bar_positions))
    for group_key, sub_keys, display, color in MERGED_GROUPS:
        counts = []
        for model in ALL_MODELS:
            for cond in CONDS:
                cell = AGG['leaderboard'].get(model, {}).get(cond)
                if cell is None:
                    counts.append(0)
                else:
                    n = cell['n']
                    s = sum(cell['outcomes'].get(k, 0) for k in sub_keys)
                    counts.append(100.0 * s / max(n, 1))
        counts = np.array(counts)
        ax.bar(
            bar_positions, counts, bottom=bottoms,
            color=color, label=display,
            edgecolor='white', linewidth=0.4, width=0.92,
        )
        bottoms += counts
    ax.set_xticks(bar_positions)
    ax.set_xticklabels(labels, fontsize=8.5)
    ax.set_ylabel('cells (\\%) - 30 problems per cell')
    ax.set_ylim(0, 100)
    ax.set_title('Outcome breakdown by (model, condition), post-audit')
    ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.16),
              ncol=5, fontsize=8.5, frameon=False)
    fig.tight_layout()
    save(fig, 'outcome-breakdown')
    plt.close(fig)


# ---------- F3 cost-pareto ----------

def fig_cost_pareto():
    print('F3 cost-pareto:')
    fig, ax = plt.subplots(figsize=(7.5, 5.2))
    markers = {'lean_only': 'o', 'with_sympy': 's'}
    color_per_model = {
        'gpt-5.5': '#1f77b4',
        'gpt-5.4-mini': '#aec7e8',
        'deepseek-v4-pro': '#ff7f0e',
        'deepseek-v4-flash': '#ffbb78',
        'claude-opus-4-7': '#9467bd',
    }
    cost_jitter = {'lean_only': 0.88, 'with_sympy': 1.14}
    label_offset = {'lean_only': (8, -10), 'with_sympy': (8, 6)}
    for model in COST_MODELS:
        for cond in CONDS:
            cell = AGG['leaderboard'].get(model, {}).get(cond)
            if cell is None or cell['n'] == 0:
                continue
            cost = cell['cost_mean_per_cell_usd']
            display_cost = max(cost, 5e-4) * cost_jitter[cond]
            pr = 100.0 * cell['pass_rate']
            ax.scatter([display_cost], [pr], s=130, marker=markers[cond],
                       facecolor=color_per_model[model],
                       edgecolor='black', linewidth=0.7, zorder=3)
            dx, dy = label_offset[cond]
            ax.annotate(
                f"{MODEL_DISPLAY[model]}",
                xy=(display_cost, pr), xytext=(dx, dy),
                textcoords='offset points', fontsize=8,
            )
    ax.set_xlabel('mean cost per cell (USD, log scale; OpenAI = \\$0 via ChatGPT subscription)')
    ax.set_ylabel('pass rate (%)')
    ax.set_title('Cost vs pass rate (8 model×condition cells)')
    ax.set_xscale('log')
    ax.set_xlim(3e-4, 0.2)
    ax.set_ylim(-2, 100)
    ax.grid(True, which='both', alpha=0.3, zorder=0)
    legend_elems = [
        plt.Line2D([0], [0], marker='o', color='w', label='lean\\_only',
                   markerfacecolor='#666', markeredgecolor='black', markersize=10),
        plt.Line2D([0], [0], marker='s', color='w', label='with\\_sympy',
                   markerfacecolor='#666', markeredgecolor='black', markersize=10),
    ]
    ax.legend(handles=legend_elems, loc='lower right', fontsize=9, frameon=False)
    fig.tight_layout()
    save(fig, 'cost-pareto')
    plt.close(fig)


# ---------- T5 hub recall (table; demoted from figure since only gpt-5.5 ran it) ----------

def _summarize_results(results: list[dict]) -> dict:
    n = len(results) or 1
    macro_p = sum(r['precision'] for r in results) / n
    macro_r = sum(r['recall'] for r in results) / n
    macro_f = sum(r['f1'] for r in results) / n
    tp = sum(r['tp'] for r in results)
    fp = sum(r['fp'] for r in results)
    fn = sum(r['fn'] for r in results)
    mp = tp / (tp + fp) if (tp + fp) else 0.0
    mr = tp / (tp + fn) if (tp + fn) else 0.0
    mf = (2 * mp * mr / (mp + mr)) if (mp + mr) else 0.0
    return {'macro': (macro_p, macro_r, macro_f),
            'micro': (mp, mr, mf), 'n': len(results)}


def table_hub_recall():
    print('T5 hub-recall:')
    sig_path = EVAL / 'hub_recall' / 'gpt-5.5' / 'aggregate.json'
    proof_path = EVAL / 'hub_recall_proof' / 'gpt-5.5' / 'aggregate.json'
    if not sig_path.exists():
        print('  no signature-only hub_recall data, skipping')
        return
    sig = json.loads(sig_path.read_text())
    sig_results = sig['results']
    sig_index = {r['problem_id']: r for r in sig_results}

    table_rows = []
    table_rows.append(('signature-only', '30', _summarize_results(sig_results)))

    if proof_path.exists():
        pr = json.loads(proof_path.read_text())
        proof_results = pr['results']
        proof_pids = sorted({r['problem_id'] for r in proof_results})
        # Restricted signature-only on the same provable subset
        sig_restricted = [sig_index[p] for p in proof_pids if p in sig_index]
        table_rows.append(('signature-only (provable subset)',
                           str(len(sig_restricted)), _summarize_results(sig_restricted)))
        table_rows.append(('proof-conditioned', str(len(proof_results)),
                           _summarize_results(proof_results)))

    lines = [
        r'\begin{table*}[!t]',
        r'  \caption{Hub-strategy classification by \texttt{gpt-5.5} against the 22-hub catalog. Macro averages per-problem P/R/F1; micro pools TP/FP/FN across problems. Signature-only feeds the model the English statement plus the Lean signature; proof-conditioned additionally feeds the complete type-checked Lean proof of the theorem. The provable subset is the 18 problems for which some model in the proving evaluation produced a passing Lean proof.}',
        r'  \label{tab:hub-recall}',
        r'  \small',
        r'  \centering',
        r'  \begin{tabular}{llrrrrrr}',
        r'    \toprule',
        r'    & & \multicolumn{3}{c}{macro} & \multicolumn{3}{c}{micro} \\',
        r'    \cmidrule(lr){3-5} \cmidrule(lr){6-8}',
        r'    Setting & N & P & R & $F_1$ & P & R & $F_1$ \\',
        r'    \midrule',
    ]
    for name, n, s in table_rows:
        mp, mr, mf = s['macro']
        ip, ir, ifl = s['micro']
        lines.append(
            f"    {name} & {n} & {mp:.2f} & {mr:.2f} & {mf:.2f} "
            f"& {ip:.2f} & {ir:.2f} & {ifl:.2f} \\\\"
        )
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table*}']
    (TAB / 'hub-recall.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "hub-recall.tex"}')


# ---------- T1 main pass-rate ----------

def table_main_pass_rate():
    print('T1 main-pass-rate:')
    rows = []
    for model in ALL_MODELS:
        lo = AGG['leaderboard'].get(model, {}).get('lean_only', {})
        ws = AGG['leaderboard'].get(model, {}).get('with_sympy', {})
        lo_n = lo.get('outcomes', {})
        ws_n = ws.get('outcomes', {})
        lo_pass = lo_n.get('lean_proof', 0) + lo_n.get('sympy_rescue', 0)
        ws_pass = ws_n.get('lean_proof', 0) + ws_n.get('sympy_rescue', 0)
        rows.append(
            (MODEL_DISPLAY[model], lo_pass, lo.get('n', 0),
             ws_pass, ws.get('n', 0))
        )
    lines = [
        r'\begin{table}[h]',
        r'  \caption{Pass rate by model and condition on the 30-problem stratified sample.}',
        r'  \label{tab:main-pass-rate}',
        r'  \small',
        r'  \begin{tabular}{lrr}',
        r'    \toprule',
        r'    Model & \texttt{lean\_only} & \texttt{with\_sympy} \\',
        r'    \midrule',
    ]
    MIN_N = 10  # suppress partial runs from the headline table
    for name, lp, ln, wp, wn in rows:
        lo_cell = f'{lp}/{ln} ({100*lp/max(ln,1):.0f}\\%)' if ln >= MIN_N else '---'
        ws_cell = f'{wp}/{wn} ({100*wp/max(wn,1):.0f}\\%)' if wn >= MIN_N else '---'
        lines.append(f'    {name} & {lo_cell} & {ws_cell} \\\\')
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table}']
    (TAB / 'main-pass-rate.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "main-pass-rate.tex"}')


# ---------- T2 capability decomposition ----------

def table_capability_decomposition():
    print('T2 capability-decomposition:')
    by_vendor = TC['by_vendor']
    labels = ['different_plan', 'same_plan_search_diff', 'same_plan_lean_impl_diff']
    lines = [
        r'\begin{table*}[!t]',
        r'  \caption{LLM-judge failure-layer attribution on disagreement cells (one model passed, the other failed) within each vendor pair.}',
        r'  \label{tab:capability-decomposition}',
        r'  \small',
        r'  \centering',
        r'  \begin{tabular}{lcccc}',
        r'    \toprule',
        r'    Vendor pair & disagree & diff.\ plan & search & Lean impl. \\',
        r'    \midrule',
    ]
    rename = {'openai': 'gpt-5.5 / gpt-5.4-mini',
              'deepseek': 'deepseek pro / flash'}
    for vendor, label in rename.items():
        d = by_vendor.get(vendor, {})
        n = sum(d.get(k, 0) for k in labels)
        lines.append(
            f"    {label} & {n} & {d.get('different_plan', 0)} "
            f"& {d.get('same_plan_search_diff', 0)} "
            f"& {d.get('same_plan_lean_impl_diff', 0)} \\\\"
        )
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table*}']
    (TAB / 'capability-decomposition.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "capability-decomposition.tex"}')


# ---------- T3 runtime & cost ----------

def table_runtime_cost():
    print('T3 runtime-cost:')
    lines = [
        r'\begin{table}[h]',
        r'  \caption{Runtime and cost per cell on the 30-problem sample. Wall seconds are reported as median / p90 / max to reduce sensitivity to the small number of cells that run to the wall budget. Cost is the OpenCode-reported per-cell mean in USD; the OpenAI rows are \$0 because those calls go through the ChatGPT subscription (OAuth, no per-call billing) rather than the OpenAI pay-per-token API.}',
        r'  \label{tab:runtime-cost}',
        r'  \small',
        r'  \begin{tabular}{llrrrr}',
        r'    \toprule',
        r'    Model & Cond & wall median & wall p90 & wall max & mean \$/cell \\',
        r'    \midrule',
    ]
    for model in COST_MODELS:
        for cond in CONDS:
            cell = AGG['leaderboard'].get(model, {}).get(cond)
            if cell is None:
                continue
            w = cell['wall_seconds']
            lines.append(
                f"    {MODEL_DISPLAY[model]} & \\texttt{{{cond.replace('_', '\\_')}}} "
                f"& {w.get('median', 0):.1f} & {w.get('p90', 0):.1f} & {w.get('max', 0):.1f} "
                f"& {cell['cost_mean_per_cell_usd']:.4f} \\\\"
            )
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table}']
    (TAB / 'runtime-cost.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "runtime-cost.tex"}')


# ---------- T4 partial Opus head-to-head ----------

def table_partial_opus():
    print('T4 partial-opus:')
    relation = TC55['plan_relation_counts']
    divergence = TC55['divergence_counts']
    n = TC55['n_problems']

    def _pass_count(model: str, cond: str = 'lean_only') -> tuple[int, int]:
        d = EVAL / model / cond
        passes = 0
        total = 0
        if not d.exists():
            return passes, total
        for pid_dir in sorted(d.iterdir()):
            if not pid_dir.is_dir():
                continue
            oc_path = pid_dir / 'outcome.json'
            if not oc_path.exists():
                continue
            oc = json.loads(oc_path.read_text())
            total += 1
            if oc.get('outcome') in ('lean_proof', 'sympy_rescue'):
                passes += 1
        return passes, total

    a_pass, a_total = _pass_count('gpt-5.5', 'lean_only')
    b_pass, b_total = _pass_count('claude-opus-4-7', 'lean_only')

    both_pass = 0
    only_a = 0
    only_b = 0
    neither = 0
    a_dir = EVAL / 'gpt-5.5' / 'lean_only'
    b_dir = EVAL / 'claude-opus-4-7' / 'lean_only'
    common_pids = sorted(set(p.name for p in a_dir.iterdir() if p.is_dir())
                         & set(p.name for p in b_dir.iterdir() if p.is_dir()))
    for pid in common_pids:
        a_oc = json.loads((a_dir / pid / 'outcome.json').read_text())
        b_oc = json.loads((b_dir / pid / 'outcome.json').read_text())
        a_ok = a_oc.get('outcome') in ('lean_proof', 'sympy_rescue')
        b_ok = b_oc.get('outcome') in ('lean_proof', 'sympy_rescue')
        if a_ok and b_ok:
            both_pass += 1
        elif a_ok:
            only_a += 1
        elif b_ok:
            only_b += 1
        else:
            neither += 1
    lines = [
        r'\begin{table}[!t]',
        r'  \caption{Partial \texttt{claude-opus-4-7} head-to-head with \texttt{gpt-5.5} on all 30 problems under the \texttt{lean\_only} condition (\texttt{with\_sympy} was not run on Opus due to budget). Pass counts are post-audit. Plan-relation and divergence are LLM-judge labels from the same rubric as Table~\ref{tab:capability-decomposition}.}',
        r'  \label{tab:partial-opus}',
        r'  \small',
        r'  \begin{tabular}{lr}',
        r'    \toprule',
        f'    gpt-5.5 passes & {a_pass}/{a_total} \\\\',
        f'    claude-opus-4-7 passes & {b_pass}/{b_total} \\\\',
        r'    \midrule',
        f'    both pass / only gpt-5.5 / only Opus / neither & {both_pass} / {only_a} / {only_b} / {neither} \\\\',
        r'    \midrule',
        r'    \multicolumn{2}{l}{\textit{plan relation (LLM judge)}} \\',
        f"    \\quad same\\_plan / different\\_plan / unclear & {relation.get('same_plan', 0)} / {relation.get('different_plan', 0)} / {relation.get('unclear', 0)} \\\\",
        r'    \multicolumn{2}{l}{\textit{divergence (LLM judge)}} \\',
        f"    \\quad none / search / lean\\_impl / instr.-follow / n/a & {divergence.get('none', 0)} / {divergence.get('search', 0)} / {divergence.get('lean_impl', 0)} / {divergence.get('instruction_following', 0)} / {divergence.get('n/a', 0)} \\\\",
        r'    \bottomrule',
        r'  \end{tabular}',
        r'\end{table}',
    ]
    (TAB / 'partial-opus.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "partial-opus.tex"}')


def table_runtime():
    print('T3 runtime:')
    lines = [
        r'\begin{table}[!t]',
        r'  \caption{Runtime per cell on the 30-problem sample, by (model, condition).}',
        r'  \label{tab:runtime}',
        r'  \small',
        r'  \begin{tabular}{llrrr}',
        r'    \toprule',
        r'    Model & Cond & median & p90 & max \\',
        r'    \midrule',
    ]
    for model in ALL_MODELS:
        for cond in CONDS:
            cell = AGG['leaderboard'].get(model, {}).get(cond)
            if cell is None:
                continue
            w = cell['wall_seconds']
            lines.append(
                f"    {MODEL_DISPLAY[model]} & \\texttt{{{cond.replace('_', '\\_')}}} "
                f"& {w.get('median', 0):.0f} & {w.get('p90', 0):.0f} & {w.get('max', 0):.0f} \\\\"
            )
    lines += [r'    \bottomrule', r'  \end{tabular}', r'\end{table}']
    (TAB / 'runtime.tex').write_text('\n'.join(lines) + '\n')
    print(f'  wrote {TAB / "runtime.tex"}')


def main():
    fig_outcome_breakdown()
    table_main_pass_rate()
    table_capability_decomposition()
    table_runtime()
    table_partial_opus()
    table_hub_recall()


if __name__ == '__main__':
    main()
