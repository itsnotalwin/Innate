#!/usr/bin/env python3
"""Draw tiny native-scale dragonfly frames for the pond garden."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/sprout_lands/pond_life.png'
COLORS = [
    ((111, 151, 147, 255), (190, 214, 199, 255)),
    ((137, 128, 172, 255), (211, 202, 218, 255)),
    ((202, 139, 148, 255), (237, 195, 188, 255)),
]

atlas = Image.new('RGBA', (64, 48))
for color_row, (body, wings) in enumerate(COLORS):
    for frame in range(4):
        image = Image.new('RGBA', (16, 16))
        pixels = image.load()
        # A two-pixel body and tail, with alternating wing angles.
        pixels[8, 6] = body
        pixels[8, 7] = body
        pixels[8, 8] = body
        pixels[8, 9] = body
        pixels[8, 10] = body
        pixels[7, 5] = wings
        pixels[8, 5] = wings
        pixels[9, 5] = wings
        if frame % 2 == 0:
            for x, y in [(5, 6), (6, 6), (10, 6), (11, 6), (6, 8), (10, 8)]: pixels[x, y] = wings
        else:
            for x, y in [(6, 4), (7, 5), (9, 5), (10, 4), (6, 9), (10, 9)]: pixels[x, y] = wings
        atlas.alpha_composite(image, (frame * 16, color_row * 16))
OUT.parent.mkdir(parents=True, exist_ok=True)
atlas.save(OUT)
print(f'Prepared {OUT.relative_to(ROOT)}')
