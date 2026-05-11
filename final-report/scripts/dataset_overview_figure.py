"""Regenerate the dataset-overview figure from the current d2_curation_v2 dataset.

Output: report-artifacts/figures/dataset-overview.png
Left panel: degree distribution across the 461 nodes (problems vs hubs colored separately).
Right panel: top-10 hubs by degree as a horizontal bar chart with readable labels.
"""

import json
from collections import Counter
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

matplotlib.rcParams['font.family'] = ['DejaVu Sans', 'sans-serif']
matplotlib.rcParams['figure.dpi'] = 200

ROOT = Path('/home/raven/Desktop/lean')
DATASET = ROOT / 'final-presentation' / 'd2_curation_v2' / 'data' / 'dataset_v2'
NODES_DIR = DATASET / 'nodes'
EDGES_FILE = DATASET / 'edges.json'
OUT = ROOT / 'final-report' / 'report-artifacts' / 'figures' / 'dataset-overview.png'

HUB_DISPLAY = {
    'basic-methods-in-analysis-i-hub': 'Basic Methods in Analysis I',
    'term-by-term-estimates-hub': 'Term-by-Term Estimates',
    'an-epsilon-of-room-hub': 'An Epsilon of Room',
    'piecewise-estimates-hub': 'Piecewise Estimates',
    'integral-estimates-for-sums-hub': 'Integral Estimates for Sums',
    'nonexistence-of-a-limit-for-sine-on-the-integers-hub': 'Sine Has No Integer Limit',
    'using-known-asymptotics-to-derive-expansions-hub': 'Asymptotics to Expansions',
    'borel-cantelli-lemma-and-applications-hub': 'Borel-Cantelli Lemma',
    'sum-estimates-via-summation-by-parts-hub': 'Summation by Parts',
    'an-epsilon-of-room-for-measure-zero-sets-hub': 'Epsilon of Room (Measure Zero)',
}


def main():
    edges = json.loads(EDGES_FILE.read_text())
    deg = Counter()
    for e in edges:
        deg[e['a']] += 1
        deg[e['b']] += 1

    problem_ids, hub_ids, hub_titles = set(), set(), {}
    for f in NODES_DIR.glob('*.json'):
        d = json.loads(f.read_text())
        if d.get('type') == 'problem':
            problem_ids.add(d['id'])
        elif d.get('type') == 'hub':
            hub_ids.add(d['id'])
            hub_titles[d['id']] = HUB_DISPLAY.get(d['id'], d['id'].replace('-', ' '))

    problem_degs = [deg[p] for p in problem_ids]
    hub_degs = [deg[h] for h in hub_ids]

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5))

    # Left: degree distribution, problems vs hubs overlaid
    max_deg = max(max(problem_degs), max(hub_degs))
    bins = np.linspace(0, max_deg + 1, 40)
    axes[0].hist(problem_degs, bins=bins, color='#4C72B0', alpha=0.85, label=f'Problems ({len(problem_ids)})', edgecolor='white', linewidth=0.4)
    axes[0].hist(hub_degs, bins=bins, color='#C44E52', alpha=0.85, label=f'Hubs ({len(hub_ids)})', edgecolor='white', linewidth=0.4)
    axes[0].set_xlabel('Node degree', fontsize=11)
    axes[0].set_ylabel('Number of nodes', fontsize=11)
    axes[0].set_title(f'Degree distribution ({len(problem_ids) + len(hub_ids)} nodes, {len(edges):,} edges)', fontsize=12, fontweight='bold')
    axes[0].set_yscale('log')
    axes[0].legend(fontsize=10, loc='upper right')

    # Right: top-10 hubs by degree, horizontal bars
    top10 = sorted(hub_ids, key=lambda h: -deg[h])[:10]
    labels = [hub_titles[h] for h in top10]
    degrees = [deg[h] for h in top10]
    y = np.arange(len(top10))
    axes[1].barh(y, degrees, color='#C44E52', alpha=0.85, edgecolor='white', linewidth=0.5)
    axes[1].set_yticks(y)
    axes[1].set_yticklabels(labels, fontsize=9)
    axes[1].invert_yaxis()
    axes[1].set_xlabel('Degree', fontsize=11)
    axes[1].set_title('Top 10 strategy hubs by degree', fontsize=12, fontweight='bold')
    for i, d in enumerate(degrees):
        axes[1].text(d + 1, i, str(d), va='center', fontsize=9)
    axes[1].set_xlim(0, max(degrees) * 1.12)

    plt.tight_layout()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(OUT, bbox_inches='tight', facecolor='white')
    print(f'Wrote {OUT}')


if __name__ == '__main__':
    main()
