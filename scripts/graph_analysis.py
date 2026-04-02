"""Structural analysis of the math knowledge graph for presentation slides."""

import re
import os
from collections import Counter
from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.family'] = ['DejaVu Sans', 'sans-serif']
matplotlib.rcParams['figure.dpi'] = 150

MATH_DIR = Path("math-notes/笔记共享vault/math")
OUT_DIR = Path("figures")
OUT_DIR.mkdir(exist_ok=True)

# --- Parse the graph ---
link_pattern = re.compile(r'\[\[([^\]]+)\]\]')

# Count in-degree (how many times each note is linked TO)
in_degree = Counter()
# Count out-degree (how many links each note contains)
out_degree = {}

for md_file in MATH_DIR.glob("*.md"):
    name = md_file.stem
    content = md_file.read_text(encoding='utf-8')
    links = link_pattern.findall(content)
    # Strip section anchors
    targets = [l.split('#')[0] for l in links if l.split('#')[0]]
    out_degree[name] = len(targets)
    for t in targets:
        in_degree[t] += 1

all_nodes = set(f.stem for f in MATH_DIR.glob("*.md"))
total_nodes = len(all_nodes)
total_edges = sum(in_degree.values())

# Ensure every node has an in-degree entry
for n in all_nodes:
    if n not in in_degree:
        in_degree[n] = 0

in_degrees = sorted(in_degree.values(), reverse=True)

# --- Figure 1: In-degree distribution (log-scale histogram) ---
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Left: histogram
degrees = list(in_degree.values())
max_deg = max(degrees)
bins = np.arange(0, max_deg + 2) - 0.5

axes[0].hist(degrees, bins=bins, color='#4C72B0', edgecolor='white', linewidth=0.5)
axes[0].set_xlabel('In-degree (times referenced)', fontsize=12)
axes[0].set_ylabel('Number of nodes', fontsize=12)
axes[0].set_title('Node In-Degree Distribution', fontsize=13, fontweight='bold')
axes[0].set_yscale('log')
axes[0].set_xlim(-0.5, 60)

# Annotate tiers
axes[0].axvspan(-0.5, 2.5, alpha=0.08, color='blue', label='Leaf (1-2)')
axes[0].axvspan(2.5, 9.5, alpha=0.08, color='orange', label='Medium (3-9)')
axes[0].axvspan(9.5, 60, alpha=0.08, color='red', label='Hub (10+)')
axes[0].legend(fontsize=9, loc='upper right')

# Right: Rank plot (shows power-law clearly)
ranks = np.arange(1, len(in_degrees) + 1)
axes[1].plot(ranks, in_degrees, color='#C44E52', linewidth=2)
axes[1].fill_between(ranks, in_degrees, alpha=0.15, color='#C44E52')
axes[1].set_xlabel('Node rank', fontsize=12)
axes[1].set_ylabel('In-degree', fontsize=12)
axes[1].set_title('In-Degree Rank Plot (Power Law)', fontsize=13, fontweight='bold')
axes[1].set_yscale('log')
axes[1].set_xscale('log')

# Annotate top hubs
top5 = in_degree.most_common(5)
rank_translations = {
    '逐项估计': 'Term-by-term est.',
    '和的积分估计': 'Integral est. of sums',
    '分段估计': 'Segmented est.',
    'an epsilon of room': 'Epsilon of room',
    '函数与序列的上下极限': 'Limsup/liminf',
}
for i, (name, deg) in enumerate(top5):
    short = rank_translations.get(name, name[:20])
    axes[1].annotate(f'{short} ({deg})',
                     xy=(i + 1, deg),
                     xytext=(i + 1 + 8, deg * 0.7),
                     fontsize=7,
                     arrowprops=dict(arrowstyle='->', color='gray', lw=0.8))

plt.tight_layout()
plt.savefig(OUT_DIR / 'degree_distribution.png', bbox_inches='tight')
print(f"Saved: {OUT_DIR / 'degree_distribution.png'}")

# --- Figure 2: Tier breakdown (pie + bar) ---
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Classify
hubs = [(n, d) for n, d in in_degree.items() if d >= 10]
medium = [(n, d) for n, d in in_degree.items() if 3 <= d < 10]
leaves = [(n, d) for n, d in in_degree.items() if 1 <= d <= 2]
isolated = [(n, d) for n, d in in_degree.items() if d == 0]

tier_counts = [len(hubs), len(medium), len(leaves), len(isolated)]
tier_labels = [
    f'Hub (deg 10+)\n{len(hubs)} nodes',
    f'Medium (deg 3-9)\n{len(medium)} nodes',
    f'Leaf (deg 1-2)\n{len(leaves)} nodes',
    f'Isolated (deg 0)\n{len(isolated)} nodes'
]
colors = ['#C44E52', '#DD8452', '#4C72B0', '#CCCCCC']

axes[0].pie(tier_counts, labels=tier_labels, colors=colors,
            autopct='%1.0f%%', startangle=90, textprops={'fontsize': 10})
axes[0].set_title(f'Node Classification ({total_nodes} total)', fontsize=13, fontweight='bold')

# Right: top 15 hub nodes as horizontal bar
# English translations for display
name_translations = {
    '逐项估计': 'Term-by-term estimation',
    '和的积分估计': 'Integral estimation of sums',
    '分段估计': 'Segmented estimation',
    'an epsilon of room': 'An epsilon of room',
    '函数与序列的上下极限': 'Limsup/liminf of functions & sequences',
    'Borel-Cantelli lemma及其应用': 'Borel-Cantelli lemma & applications',
    '基于分部求和法的和的估计': 'Summation by parts estimates',
    '柯西凝聚判别法': 'Cauchy condensation test',
    'approximation to the identity': 'Approximation to the identity',
    '模1均匀分布与Weyl判别': 'Equidistribution mod 1 & Weyl criterion',
    '无理测度的定义以及基本的命题': 'Irrationality measure',
    'Re0微积分1：用牛顿迭代法求算术平方根': 'Newton iteration for sqrt',
    '把条件函数展开为新的和或积分然后换序': 'Expand indicator & swap order',
    '序列差分的估计蕴含着序列本身的估计': 'Difference estimates imply sequence estimates',
    'identity theorem': 'Identity theorem',
}
top_hubs = sorted(hubs, key=lambda x: x[1], reverse=True)[:15]
names = [name_translations.get(n, n[:30]) for n, _ in top_hubs]
degs = [d for _, d in top_hubs]

y_pos = np.arange(len(names))
axes[1].barh(y_pos, degs, color='#C44E52', edgecolor='white')
axes[1].set_yticks(y_pos)
axes[1].set_yticklabels(names, fontsize=8)
axes[1].invert_yaxis()
axes[1].set_xlabel('In-degree', fontsize=12)
axes[1].set_title('Top 15 Hub Nodes (Strategy Templates)', fontsize=13, fontweight='bold')

for i, d in enumerate(degs):
    axes[1].text(d + 0.5, i, str(d), va='center', fontsize=9)

plt.tight_layout()
plt.savefig(OUT_DIR / 'tier_breakdown.png', bbox_inches='tight')
print(f"Saved: {OUT_DIR / 'tier_breakdown.png'}")

# --- Figure 3: Summary stats card ---
fig, ax = plt.subplots(figsize=(8, 4))
ax.axis('off')

stats = [
    ('Total nodes', str(total_nodes)),
    ('Total edges', str(total_edges)),
    ('Avg links/node', f'{total_edges / total_nodes:.1f}'),
    ('Hub nodes (deg 10+)', f'{len(hubs)} ({100*len(hubs)/total_nodes:.0f}%)'),
    ('Medium nodes (deg 3-9)', f'{len(medium)} ({100*len(medium)/total_nodes:.0f}%)'),
    ('Leaf nodes (deg 1-2)', f'{len(leaves)} ({100*len(leaves)/total_nodes:.0f}%)'),
    ('Max in-degree', f'{top5[0][1]} (Term-by-term estimation)'),
]

table = ax.table(
    cellText=[[k, v] for k, v in stats],
    colLabels=['Metric', 'Value'],
    cellLoc='left',
    loc='center',
    colWidths=[0.5, 0.4]
)
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1, 1.8)

# Style header
for j in range(2):
    table[0, j].set_facecolor('#4C72B0')
    table[0, j].set_text_props(color='white', fontweight='bold')

ax.set_title('Knowledge Graph: Summary Statistics', fontsize=14, fontweight='bold', pad=20)

plt.savefig(OUT_DIR / 'summary_stats.png', bbox_inches='tight')
print(f"Saved: {OUT_DIR / 'summary_stats.png'}")

print("\nDone. All figures in figures/")
