"""
Render a LaTeX math expression to a tightly-cropped PNG via matplotlib's
mathtext (no pdflatex required).

Usage:
    python3 _render_equation.py "H_n := \\sum_{k=1}^{n} \\frac{1}{k}" out.png [fontsize]

Notes:
- Use matplotlib mathtext, which supports a broad subset of LaTeX math.
- DPI 300, transparent background, tight bbox.
- The argument is the math content (no surrounding $...$).
"""
import sys
import matplotlib.pyplot as plt
from matplotlib import rcParams


def render(latex_math: str, out_path: str, fontsize: int = 36):
    rcParams["mathtext.fontset"] = "cm"  # Computer Modern (LaTeX-style)
    fig = plt.figure(figsize=(0.01, 0.01))
    fig.text(0, 0, f"${latex_math}$", fontsize=fontsize)
    fig.savefig(out_path, dpi=300, bbox_inches="tight", pad_inches=0.05, transparent=True)
    plt.close(fig)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: _render_equation.py <latex> <out_png> [fontsize]", file=sys.stderr)
        sys.exit(1)
    fontsize = int(sys.argv[3]) if len(sys.argv) > 3 else 36
    render(sys.argv[1], sys.argv[2], fontsize=fontsize)
    print(f"Wrote {sys.argv[2]}")
