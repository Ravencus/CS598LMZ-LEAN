"""Render a green-square-with-white-check icon PNG (transparent bg)."""
from PIL import Image, ImageDraw

SIZE = 256  # high-res; deckforge will scale

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Rounded green square
GREEN = (33, 153, 84, 255)  # solid green
PAD = int(SIZE * 0.08)
RADIUS = int(SIZE * 0.18)
draw.rounded_rectangle(
    [PAD, PAD, SIZE - PAD, SIZE - PAD],
    radius=RADIUS,
    fill=GREEN,
)

# White checkmark — three points: left, bottom-center, top-right
WHITE = (255, 255, 255, 255)
THICK = int(SIZE * 0.08)

# Coordinates as fractions of SIZE
points = [
    (0.27, 0.55),  # left
    (0.45, 0.72),  # elbow
    (0.74, 0.36),  # top right
]
xy = [(int(x * SIZE), int(y * SIZE)) for x, y in points]
draw.line(xy, fill=WHITE, width=THICK, joint="curve")

# Round caps on the line ends
for px, py in [xy[0], xy[2]]:
    r = THICK // 2
    draw.ellipse([px - r, py - r, px + r, py + r], fill=WHITE)

img.save("/workspace/final-presentation/slides/figures/icon_check.png")
print("Wrote icon_check.png")
