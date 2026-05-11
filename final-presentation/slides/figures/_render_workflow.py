"""Render the old vs. new workflow comparison as a PNG."""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

GREEN_FILL = "#c6efce"
GREEN_EDGE = "#1f7a3a"
RED_FILL = "#ffc7ce"
RED_EDGE = "#a14d3a"
NEUTRAL_FILL = "#eef2f7"
NEUTRAL_EDGE = "#3a4858"

fig, axes = plt.subplots(1, 2, figsize=(16, 6.5), gridspec_kw={"width_ratios": [1, 1.6]})

def box(ax, x, y, w, h, text, fill=NEUTRAL_FILL, edge=NEUTRAL_EDGE, fs=11, weight="normal"):
    rect = FancyBboxPatch(
        (x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.06",
        linewidth=1.6, edgecolor=edge, facecolor=fill,
    )
    ax.add_patch(rect)
    ax.text(x + w/2, y + h/2, text, ha="center", va="center",
            fontsize=fs, fontweight=weight, color="#1a1a1a")

def arrow(ax, x1, y1, x2, y2, label=None, color="#3a4858", labelpos=None):
    a = FancyArrowPatch(
        (x1, y1), (x2, y2),
        arrowstyle="-|>", mutation_scale=14,
        color=color, linewidth=1.4,
    )
    ax.add_patch(a)
    if label:
        if labelpos:
            mx, my = labelpos
        else:
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx, my, label, ha="center", va="center", fontsize=9,
                color=color, bbox=dict(facecolor="white", edgecolor="none", pad=1.5))

# ---------------- LEFT panel: Old workflow ----------------
ax = axes[0]
ax.set_xlim(0, 10); ax.set_ylim(0, 10); ax.axis("off")
ax.set_title("Old: Lean-only loop", fontsize=15, fontweight="bold", color="#222222", pad=10)

# Vertical chain
box(ax, 3.0, 8.4, 4, 0.9, "Problem", fill="#f1f5f9", fs=12, weight="bold")
arrow(ax, 5, 8.4, 5, 7.7)
box(ax, 3.0, 6.8, 4, 0.9, "Plan", fs=12)
arrow(ax, 5, 6.8, 5, 6.1)
box(ax, 3.0, 5.2, 4, 0.9, "Execute (Lean)", fs=12)
arrow(ax, 5, 5.2, 5, 4.5)
box(ax, 3.0, 3.6, 4, 0.9, "Compile", fs=12)
arrow(ax, 5, 3.6, 5, 2.9, label="✓")
box(ax, 3.0, 2.0, 4, 0.9, "Done", fill=GREEN_FILL, edge=GREEN_EDGE, fs=12, weight="bold")

# Feedback arrow: Compile -> Plan (curved, dashed)
fb = FancyArrowPatch(
    (7.0, 4.05), (7.0, 7.25),
    arrowstyle="-|>", mutation_scale=14, color=RED_EDGE,
    linewidth=1.4, linestyle="--",
    connectionstyle="arc3,rad=0.5",
)
ax.add_patch(fb)
ax.text(8.7, 5.6, "error\n(revise plan)", ha="center", va="center",
        fontsize=10, color=RED_EDGE, style="italic")

# ---------------- RIGHT panel: New workflow ----------------
ax = axes[1]
ax.set_xlim(0, 16); ax.set_ylim(0, 10); ax.axis("off")
ax.set_title("New: sorry-with-witness, multi-tool", fontsize=15, fontweight="bold", color="#222222", pad=10)

# Top chain: Problem -> Decompose -> Classify
box(ax, 0.5, 8.4, 2.8, 0.9, "Problem", fill="#f1f5f9", fs=12, weight="bold")
arrow(ax, 3.3, 8.85, 4.0, 8.85)
box(ax, 4.0, 8.4, 3.4, 0.9, "Decompose", fs=12)
arrow(ax, 7.4, 8.85, 8.1, 8.85)
box(ax, 8.1, 8.4, 4.4, 0.9, "Classify (per subgoal)", fs=12)

# Three tool branches — all originate from the bottom-center of Classify
classify_cx = 10.3
arrow(ax, classify_cx, 8.4, 2.9,  6.5, label="formal proof", labelpos=(5.5, 7.4))
arrow(ax, classify_cx, 8.4, 8.5,  6.5, label="algebra / integrals", labelpos=(9.4, 7.4))
arrow(ax, classify_cx, 8.4, 13.5, 6.5, label="constraints", labelpos=(12.7, 7.4))

box(ax,  1.4, 5.6, 3.0, 0.9, "Lean",                    fill=GREEN_FILL, edge=GREEN_EDGE, fs=12, weight="bold")
box(ax,  6.5, 5.6, 4.0, 0.9, "sympy / Mathematica",     fill=GREEN_FILL, edge=GREEN_EDGE, fs=12, weight="bold")
box(ax, 12.0, 5.6, 3.0, 0.9, "OR-Tools / Z3",           fill=RED_FILL,   edge=RED_EDGE,   fs=12, weight="bold")

# Tool outputs converge to "Check result" (centered at x=8)
check_cx = 8.0
arrow(ax,  2.9, 5.6, check_cx, 4.4)
arrow(ax,  8.5, 5.6, check_cx, 4.4)
arrow(ax, 13.5, 5.6, check_cx, 4.4)

box(ax, check_cx - 2.0, 3.5, 4.0, 0.9, "Check result", fs=12, weight="bold")

# Done branch
arrow(ax, check_cx, 3.5, check_cx, 2.8, label="✓")
box(ax, check_cx - 2.4, 1.9, 4.8, 0.9, "= witness (proof)", fill=GREEN_FILL, edge=GREEN_EDGE, fs=12, weight="bold")

# Feedback loop: Check result -> Decompose (replan)
fb2 = FancyArrowPatch(
    (check_cx - 2.0, 3.95), (5.5, 8.4),
    arrowstyle="-|>", mutation_scale=14, color=RED_EDGE,
    linewidth=1.4, linestyle="--",
    connectionstyle="arc3,rad=-0.45",
)
ax.add_patch(fb2)
ax.text(2.0, 4.6, "error\n(replan)", ha="center", va="center",
        fontsize=10, color=RED_EDGE, style="italic")

plt.tight_layout()
out = "/workspace/final-presentation/slides/figures/workflow_old_vs_new.png"
plt.savefig(out, dpi=200, bbox_inches="tight", facecolor="white")
plt.close()
print(f"Wrote {out}")
