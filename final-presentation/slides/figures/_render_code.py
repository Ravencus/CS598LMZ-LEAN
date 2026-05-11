"""
Render a source-code snippet to a PNG with syntax highlighting via pygments.

Usage:
    python3 _render_code.py <input.lean> <output.png> [lexer=lean4] [font_size=20]
"""
import sys
from pathlib import Path
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import ImageFormatter


def main():
    if len(sys.argv) < 3:
        print("Usage: _render_code.py <in_file> <out_png> [lexer] [font_size]", file=sys.stderr)
        sys.exit(1)
    in_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    lexer_name = sys.argv[3] if len(sys.argv) > 3 else "lean4"
    font_size = int(sys.argv[4]) if len(sys.argv) > 4 else 20

    code = in_path.read_text(encoding="utf-8")

    lexer = get_lexer_by_name(lexer_name)
    formatter = ImageFormatter(
        font_name="DejaVu Sans Mono",
        font_size=font_size,
        line_numbers=False,
        style="default",  # light, white-bg friendly
        image_pad=14,
        line_pad=4,
    )

    out_bytes = highlight(code, lexer, formatter)
    out_path.write_bytes(out_bytes)
    print(f"Wrote {out_path} ({len(out_bytes)} bytes)")


if __name__ == "__main__":
    main()
