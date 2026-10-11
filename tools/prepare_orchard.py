#!/usr/bin/env python3
"""Build native tree recolors and convert the edited picnic master."""
from pathlib import Path
import subprocess

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "sprout_lands"


def build_tree_atlas() -> None:
    base = Image.open(ASSETS / "nature.png").convert("RGBA").crop((48, 0, 80, 32))
    original = ("8a4a70", "a35b70", "af6776", "bd757e", "d99a9a", "e8b5ac")
    palettes = [
        original,
        ("90625d", "aa7959", "c49a6c", "dcb98a", "e8cfa6", "f6e2b1"),
        ("5f7a79", "6e967c", "97bb8e", "aed499", "c2e09a", "e0eeb3"),
        ("504086", "674a8b", "805891", "996c97", "b88baa", "d6b0bf"),
    ]

    def rgba(value: str) -> tuple[int, int, int, int]:
        return (*tuple(bytes.fromhex(value)), 255)

    atlas = Image.new("RGBA", (128, 32))
    for index, palette in enumerate(palettes):
        mapping = {rgba(a): rgba(b) for a, b in zip(original, palette)}
        tree = base.copy()
        tree.putdata([mapping.get(pixel, pixel) for pixel in tree.get_flattened_data()])
        atlas.alpha_composite(tree, (index * 32, 0))
    atlas.save(ASSETS / "orchard_trees.png")


if __name__ == "__main__":
    build_tree_atlas()
    subprocess.run(["godot", "--headless", "--path", str(ROOT),
                    "--script", "tools/prepare_picnic.gd"], check=True)
    print("Prepared native tree recolors and refined picnic props.")
