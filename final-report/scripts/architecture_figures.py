#!/usr/bin/env python3
"""Generate architecture figures: curation pipeline and proving harness.

Outputs:
  report-artifacts/figures/figure-curation.pdf
  report-artifacts/figures/figure-harness.pdf
"""
from __future__ import annotations
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.lines import Line2D

REPO = Path(__file__).resolve().parents[1]
FIGS = REPO / 'report-artifacts' / 'figures'
FIGS.mkdir(parents=True, exist_ok=True)

DET_FILL = '#D6E6F5'
DET_EDGE = '#3A6EA5'
LLM_FILL = '#FCE4C8'
LLM_EDGE = '#C97A2A'
INOUT_FILL = '#E6E6E6'
INOUT_EDGE = '#555555'
HARNESS_FILL = '#FFFFFF'
HARNESS_EDGE = '#333333'


def _box(ax, x, y, w, h, label, fill, edge, fontsize=9, lw=1.2):
    p = FancyBboxPatch((x, y), w, h,
                       boxstyle='round,pad=0.02,rounding_size=0.05',
                       linewidth=lw, edgecolor=edge, facecolor=fill, zorder=2)
    ax.add_patch(p)
    ax.text(x + w / 2, y + h / 2, label, ha='center', va='center',
            fontsize=fontsize, zorder=3)


def _arrow(ax, x1, y1, x2, y2, lw=1.0, style='-|>', color='#333'):
    a = FancyArrowPatch((x1, y1), (x2, y2),
                        arrowstyle=style, mutation_scale=12,
                        linewidth=lw, color=color, zorder=4)
    ax.add_patch(a)


def figure_curation():
    fig, ax = plt.subplots(figsize=(9.6, 5.6))
    ax.set_xlim(0, 11.2)
    ax.set_ylim(0, 6.8)
    ax.set_axis_off()

    stage_w = 2.5
    stage_h = 1.4
    gap = 0.3
    base_x = 2.6
    top_y = 4.6
    bot_y = 1.4
    top_mid_y = top_y + stage_h / 2
    bot_mid_y = bot_y + stage_h / 2

    # Input on top-left
    _box(ax, 0.2, top_y, 2.2, stage_h,
         'Obsidian vault\n455 notes\n[[wiki links]]',
         INOUT_FILL, INOUT_EDGE, fontsize=9)

    # Output on bottom-left
    _box(ax, 0.2, bot_y, 2.2, stage_h,
         'Relational graph\n439 problems + 22 hubs\n7,415 edges',
         INOUT_FILL, INOUT_EDGE, fontsize=9)

    stages_top = [
        ('Parse\nwiki-links\n→ note graph', 'det'),
        ('Hub\nselection\n(by degree)', 'det'),
        ('Callout\nregex parse\n(`> [!type]`)', 'det'),
    ]
    stages_bot = [
        ('Title\ntranslation\n(LLM, Codex)', 'llm'),
        ('Callout\nclassification\n4 labels (LLM)', 'llm'),
        ('Cartesian\ninheritance\n+ validate', 'det'),
    ]

    top_xs = []
    for i, (label, kind) in enumerate(stages_top):
        x = base_x + i * (stage_w + gap)
        fill = DET_FILL if kind == 'det' else LLM_FILL
        edge = DET_EDGE if kind == 'det' else LLM_EDGE
        _box(ax, x, top_y, stage_w, stage_h, label, fill, edge, fontsize=8)
        top_xs.append((x, x + stage_w))

    # Bottom row positioned R→L (snake): stage 4 on right, stage 6 on left
    bot_xs = []
    for i, (label, kind) in enumerate(stages_bot):
        col = len(stages_bot) - 1 - i  # rightmost column for first stage
        x = base_x + col * (stage_w + gap)
        fill = DET_FILL if kind == 'det' else LLM_FILL
        edge = DET_EDGE if kind == 'det' else LLM_EDGE
        _box(ax, x, bot_y, stage_w, stage_h, label, fill, edge, fontsize=8)
        bot_xs.append((x, x + stage_w))  # in flow order: bot_xs[0] is rightmost

    # Arrows: input → top1 → top2 → top3
    _arrow(ax, 2.4, top_mid_y, top_xs[0][0], top_mid_y)
    for i in range(len(top_xs) - 1):
        _arrow(ax, top_xs[i][1], top_mid_y, top_xs[i + 1][0], top_mid_y)

    # Vertical down-connector on right: top3 → bot1 (rightmost bottom box)
    right_x = top_xs[-1][1] - stage_w / 2  # center under top stage 3
    _arrow(ax, right_x, top_y, right_x, bot_y + stage_h, lw=1.0)

    # Bottom row in flow order: bot1 (right) → bot2 (mid) → bot3 (left)
    for i in range(len(bot_xs) - 1):
        _arrow(ax, bot_xs[i][0], bot_mid_y, bot_xs[i + 1][1], bot_mid_y)

    # Bottom row → output (leftmost bottom box → output box on left)
    _arrow(ax, bot_xs[-1][0], bot_mid_y, 2.4, bot_mid_y)

    # Legend
    handles = [
        mpatches.Patch(facecolor=DET_FILL, edgecolor=DET_EDGE, label='Deterministic'),
        mpatches.Patch(facecolor=LLM_FILL, edgecolor=LLM_EDGE, label='LLM-bounded (constrained output)'),
        mpatches.Patch(facecolor=INOUT_FILL, edgecolor=INOUT_EDGE, label='Input / output'),
    ]
    ax.legend(handles=handles, loc='lower center', bbox_to_anchor=(0.5, -0.02),
              ncol=3, frameon=False, fontsize=9)

    plt.subplots_adjust(left=0.01, right=0.99, top=0.99, bottom=0.10)
    out = FIGS / 'figure-curation.pdf'
    plt.savefig(out, bbox_inches='tight', pad_inches=0.20)
    plt.savefig(out.with_suffix('.png'), bbox_inches='tight', pad_inches=0.20, dpi=200)
    plt.close(fig)
    print(f'wrote {out}')


def figure_harness():
    fig, ax = plt.subplots(figsize=(13.4, 4.6))
    ax.set_xlim(0, 17)
    ax.set_ylim(0, 5.4)
    ax.set_axis_off()

    # Outer Docker container box
    _box(ax, 2.0, 0.4, 12.2, 4.6,
         '', HARNESS_FILL, HARNESS_EDGE, lw=1.6)
    ax.text(2.2, 4.8, 'Docker container: Lean 4 + precompiled Mathlib',
            ha='left', va='center', fontsize=9, style='italic',
            color='#333')

    # OpenCode agent (center)
    agent_x, agent_y, agent_w, agent_h = 6.5, 2.0, 3.4, 1.7
    _box(ax, agent_x, agent_y, agent_w, agent_h,
         'OpenCode\nagent',
         '#E8F1FB', '#3A6EA5', fontsize=11, lw=1.4)

    # System prompt: SKILL.md (top-left of agent)
    _box(ax, 2.6, 3.1, 2.6, 1.3,
         'SKILL.md\nexplore -- plan -- prove',
         DET_FILL, DET_EDGE, fontsize=8)
    _arrow(ax, 5.2, 3.55, agent_x, agent_y + agent_h * 0.7,
           lw=1.0, color='#3A6EA5')

    # Optional sympy block (bottom-left of agent, dashed)
    sx, sy, sw, sh = 2.6, 1.2, 2.6, 1.3
    p = FancyBboxPatch((sx, sy), sw, sh,
                       boxstyle='round,pad=0.02,rounding_size=0.05',
                       linewidth=1.2, edgecolor=LLM_EDGE, facecolor=LLM_FILL,
                       linestyle='--', zorder=2)
    ax.add_patch(p)
    ax.text(sx + sw / 2, sy + sh / 2,
            'sympy skill\n(optional,\nwith_sympy only)',
            ha='center', va='center', fontsize=8, zorder=3)
    _arrow(ax, 5.2, 1.85, agent_x, agent_y + agent_h * 0.3,
           lw=1.0, color=LLM_EDGE, style='-|>')

    # MCP server (right of agent)
    _box(ax, 10.6, 2.5, 3.2, 1.5,
         'MCP server\ncheck\\_lean\\_proof',
         '#E5F4E5', '#3F8B40', fontsize=9, lw=1.4)
    # arrow: agent -> MCP (call)
    _arrow(ax, agent_x + agent_w, agent_y + agent_h * 0.7,
           10.6, 2.5 + 1.5 * 0.7, lw=1.2)
    ax.text(10.45, 3.55, 'call', ha='right', va='bottom', fontsize=8)
    # arrow: MCP -> agent (diagnostic feedback)
    _arrow(ax, 10.6, 2.5 + 1.5 * 0.3,
           agent_x + agent_w, agent_y + agent_h * 0.3,
           lw=1.2, color='#777')
    ax.text(10.45, 2.7, 'diagnostic', ha='right', va='top', fontsize=8, color='#555')

    # Lean compiler below MCP
    _box(ax, 10.6, 0.7, 3.2, 1.3,
         'Lean compiler\n+ Mathlib',
         '#EEF7EE', '#3F8B40', fontsize=8)
    _arrow(ax, 10.6 + 3.2 / 2, 2.5, 10.6 + 3.2 / 2, 2.0, lw=1.0)

    # Input arrow on the left edge
    _arrow(ax, 0.4, agent_y + agent_h * 0.5, 2.0, agent_y + agent_h * 0.5, lw=1.4)
    ax.text(0.4, agent_y + agent_h * 0.5 + 0.45,
            'Problem\n(theorem signature\n+ sorry)',
            ha='left', va='bottom', fontsize=9)

    # Output arrow on the right edge
    _arrow(ax, 14.2, agent_y + agent_h * 0.5, 16.3, agent_y + agent_h * 0.5, lw=1.4)
    ax.text(16.3, agent_y + agent_h * 0.5 + 0.45,
            'Trace +\nfinal proof / outcome',
            ha='right', va='bottom', fontsize=9)

    # K=3 retry loop annotation
    ax.annotate('K=3 retry loop',
                xy=(8.2, 0.65), xytext=(8.2, 0.65),
                fontsize=8.5, ha='center', va='center', style='italic',
                color='#555')
    loop = FancyArrowPatch((agent_x + 0.6, agent_y),
                           (agent_x + agent_w - 0.6, agent_y),
                           connectionstyle='arc3,rad=-0.45',
                           arrowstyle='-|>', mutation_scale=10,
                           linewidth=0.9, color='#666',
                           linestyle=(0, (4, 3)), zorder=1)
    ax.add_patch(loop)

    plt.subplots_adjust(left=0.01, right=0.99, top=0.99, bottom=0.01)
    out = FIGS / 'figure-harness.pdf'
    plt.savefig(out, bbox_inches='tight', pad_inches=0.05)
    plt.savefig(out.with_suffix('.png'), bbox_inches='tight', pad_inches=0.05, dpi=200)
    plt.close(fig)
    print(f'wrote {out}')


if __name__ == '__main__':
    figure_curation()
    figure_harness()
