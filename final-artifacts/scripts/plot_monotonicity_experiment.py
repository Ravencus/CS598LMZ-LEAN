"""
Visualize the monotonicity experiment results.
Bar chart: failure rate per function family + summary.
"""
import json
import sys
import argparse
from pathlib import Path
from collections import Counter
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot(experiment_dir: str):
    d = Path(experiment_dir)
    summary = json.loads((d / 'summary.json').read_text())
    verifications = json.loads((d / 'verifications.json').read_text())

    total = summary['total_cases']
    holds = summary['holds_everywhere']
    failed = summary['has_counterexample']
    parse_fail = summary['parse_failed']

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: overall pie
    sizes = [holds, failed, parse_fail]
    labels = [
        f'Verified monotonic\n({holds})',
        f'Has counterexample\n({failed})',
        f'Parse failed\n({parse_fail})',
    ]
    colors = ['#4CAF50', '#E53935', '#FFC107']
    sizes_clean = [s if s > 0 else 0 for s in sizes]
    if sum(sizes_clean) > 0:
        valid_idx = [i for i, s in enumerate(sizes_clean) if s > 0]
        axes[0].pie(
            [sizes_clean[i] for i in valid_idx],
            labels=[labels[i] for i in valid_idx],
            colors=[colors[i] for i in valid_idx],
            autopct='%1.0f%%',
            startangle=90,
            textprops={'fontsize': 10},
        )
    axes[0].set_title(f'Monotonicity Experiment: {total} GPT5.4 Cases\n'
                      f'Failure rate: {summary["failure_rate"]}%',
                      fontsize=12, fontweight='bold')

    # Panel 2: by family
    total_by_fam = summary['total_by_family']
    fail_by_fam = summary['failure_by_family']
    fams = sorted(total_by_fam.keys(), key=lambda f: -total_by_fam[f])
    n = len(fams)
    x = np.arange(n)
    totals = [total_by_fam[f] for f in fams]
    fails = [fail_by_fam.get(f, 0) for f in fams]
    passes = [t - f for t, f in zip(totals, fails)]

    width = 0.6
    axes[1].bar(x, passes, width, label='Verified monotonic', color='#4CAF50')
    axes[1].bar(x, fails, width, bottom=passes, label='Has counterexample', color='#E53935')
    axes[1].set_xticks(x)
    axes[1].set_xticklabels(fams, rotation=30, ha='right', fontsize=9)
    axes[1].set_ylabel('Number of cases')
    axes[1].set_title('Failures by function family', fontsize=12, fontweight='bold')
    axes[1].legend()

    for i, (t, f) in enumerate(zip(totals, fails)):
        if f > 0:
            axes[1].text(i, t + 0.5, f'{f}/{t}', ha='center', fontsize=9, color='red')

    plt.tight_layout()
    out_path = d / 'experiment_summary.png'
    plt.savefig(out_path, dpi=120, bbox_inches='tight')
    print(f"Saved {out_path}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir',
        default='/workspace/final-presentation/d1_arbitration_case/monotonicity_experiment')
    args = parser.parse_args()
    plot(args.dir)
