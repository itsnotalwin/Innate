#!/usr/bin/env python3
"""Pack the six 256px environment sprite sheets into one shared GPU texture."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SHEETS = (
    "environment_trees",
    "mushroom_clusters",
    "flower_clumps",
    "meadow_flowers_detail",
    "meadow_patch_clusters",
    "woodland_props",
)
atlas = Image.new("RGBA", (512, 768), (0, 0, 0, 0))
for index, name in enumerate(SHEETS):
    sprite_sheet = Image.open(ROOT / "assets/innate" / f"{name}.png").convert("RGBA")
    if sprite_sheet.size != (256, 256):
        raise ValueError(f"{name} must be a 256x256 atlas, got {sprite_sheet.size}")
    atlas.alpha_composite(sprite_sheet, ((index % 2) * 256, (index // 2) * 256))
atlas.save(ROOT / "assets/innate/environment_atlas.png", optimize=True)
print(f"Packed {len(SHEETS)} sheets into assets/innate/environment_atlas.png")
