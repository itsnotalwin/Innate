"""Crop and palette-map the authored cottage trellis to a crisp game sprite."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MASTER = ROOT / "art/cottage_trellis_master.png"
PALETTE = ROOT / "assets/innate/environment_palette.json"
OUTPUT = ROOT / "assets/innate/cottage_trellis.png"


def main() -> None:
    source = Image.open(MASTER).convert("RGBA")
    visible = source.getchannel("A").point(lambda value: 255 if value > 180 else 0)
    bounds = visible.getbbox()
    if bounds is None:
        raise ValueError(f"No opaque artwork in {MASTER}")
    source = source.crop(bounds)

    max_width, max_height = 60, 68
    scale = min(max_width / source.width, max_height / source.height)
    size = (max(1, round(source.width * scale)), max(1, round(source.height * scale)))
    source = source.resize(size, Image.Resampling.NEAREST)
    palette = [
        tuple(bytes.fromhex(color.removeprefix("#")))
        for color in json.loads(PALETTE.read_text())
    ]

    output = Image.new("RGBA", (64, 72), (0, 0, 0, 0))
    left, top = (64 - source.width) // 2, 72 - source.height
    source_pixels, output_pixels = source.load(), output.load()
    for y in range(source.height):
        for x in range(source.width):
            red, green, blue, alpha = source_pixels[x, y]
            if alpha <= 180:
                continue
            color = min(
                palette,
                key=lambda candidate: (red - candidate[0]) ** 2
                + (green - candidate[1]) ** 2
                + (blue - candidate[2]) ** 2,
            )
            output_pixels[left + x, top + y] = (*color, 255)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    output.save(OUTPUT)
    print(f"Prepared cottage trellis: {OUTPUT.relative_to(ROOT)} ({output.width}x{output.height})")


if __name__ == "__main__":
    main()
