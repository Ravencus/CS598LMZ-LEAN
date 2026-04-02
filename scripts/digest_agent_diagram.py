"""Digest agent diagram for presentation slides."""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from pathlib import Path

fig, ax = plt.subplots(figsize=(12, 6))
ax.set_xlim(0, 12)
ax.set_ylim(0, 6)
ax.axis('off')

# Colors
input_color = '#4C72B0'
function_color = '#DD8452'
output_color = '#55A868'
arrow_color = '#555555'
bg_color = '#F5F5F5'

# --- Input box (left) ---
input_box = FancyBboxPatch((0.3, 2.0), 2.2, 2.0,
    boxstyle="round,pad=0.15", facecolor=input_color, edgecolor='white', alpha=0.9)
ax.add_patch(input_box)
ax.text(1.4, 3.35, 'Input', fontsize=11, fontweight='bold', ha='center', va='center', color='white')
ax.text(1.4, 2.9, 'Problem +', fontsize=9, ha='center', va='center', color='white')
ax.text(1.4, 2.55, 'Proof / Trace', fontsize=9, ha='center', va='center', color='white')

# --- Arrow: input to functions ---
ax.annotate('', xy=(3.0, 3.0), xytext=(2.6, 3.0),
    arrowprops=dict(arrowstyle='->', color=arrow_color, lw=2))

# --- Four core functions (center, 2x2 grid) ---
func_bg = FancyBboxPatch((3.0, 0.8), 5.0, 4.4,
    boxstyle="round,pad=0.2", facecolor=bg_color, edgecolor='#CCCCCC', linewidth=1.5)
ax.add_patch(func_bg)
ax.text(5.5, 5.45, 'Digest Agent — Four Core Functions', fontsize=11, fontweight='bold',
    ha='center', va='center', color='#333333')

# Function boxes
functions = [
    (3.3, 3.2, 'Reinterpretation', 'Strip surface,\nfind essential structure'),
    (5.4, 3.2, 'Scope Expansion', 'Improve bound?\nOptimal? Generalize?'),
    (3.3, 1.1, 'Progressive\nConstruction', 'Start simple (n=2),\nbuild up'),
    (5.4, 1.1, 'Strategy\nTemplates', 'Reusable patterns\nacross problems'),
]

for x, y, title, desc in functions:
    box = FancyBboxPatch((x, y), 1.9, 1.7,
        boxstyle="round,pad=0.1", facecolor=function_color, edgecolor='white', alpha=0.85)
    ax.add_patch(box)
    ax.text(x + 0.95, y + 1.15, title, fontsize=9, fontweight='bold',
        ha='center', va='center', color='white')
    ax.text(x + 0.95, y + 0.45, desc, fontsize=7.5,
        ha='center', va='center', color='white', style='italic')

# --- Arrow: functions to output ---
ax.annotate('', xy=(8.5, 3.0), xytext=(8.1, 3.0),
    arrowprops=dict(arrowstyle='->', color=arrow_color, lw=2))

# --- Output boxes (right, stacked) ---
out1 = FancyBboxPatch((8.5, 3.3), 3.2, 1.7,
    boxstyle="round,pad=0.15", facecolor=output_color, edgecolor='white', alpha=0.9)
ax.add_patch(out1)
ax.text(10.1, 4.5, 'Standalone Digest', fontsize=10, fontweight='bold', ha='center', va='center', color='white')
ax.text(10.1, 4.05, 'Full exploration output:', fontsize=8, ha='center', va='center', color='white')
ax.text(10.1, 3.7, 'strategies, connections,\nscope, templates', fontsize=8, ha='center', va='center', color='white', style='italic')

out2 = FancyBboxPatch((8.5, 1.0), 3.2, 1.7,
    boxstyle="round,pad=0.15", facecolor=output_color, edgecolor='white', alpha=0.9)
ax.add_patch(out2)
ax.text(10.1, 2.35, 'Lemma Annotations', fontsize=10, fontweight='bold', ha='center', va='center', color='white')
ax.text(10.1, 1.9, 'Strategic context on', fontsize=8, ha='center', va='center', color='white')
ax.text(10.1, 1.55, 'specific lemmas:\nwhen to use, what family', fontsize=8, ha='center', va='center', color='white', style='italic')

# --- Feedback arrow (bottom, curves back) ---
ax.annotate('', xy=(1.4, 1.8), xytext=(8.5, 0.5),
    arrowprops=dict(arrowstyle='->', color='#C44E52', lw=2,
        connectionstyle='arc3,rad=0.3'))
ax.text(5.0, 0.25, 'Fed back to prover in future sessions', fontsize=9,
    ha='center', va='center', color='#C44E52', fontweight='bold')

plt.tight_layout()
Path("figures").mkdir(exist_ok=True)
plt.savefig('figures/digest_agent_diagram.png', bbox_inches='tight', dpi=150)
print("Saved: figures/digest_agent_diagram.png")
