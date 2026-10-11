#!/usr/bin/env python3
"""Build orchard and picnic props from the project's native Sprout Lands palette."""
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "sprout_lands"


def recolor_tree(source: Image.Image, colors: tuple[tuple[int, int, int, int], ...]) -> Image.Image:
    tree = source.copy()
    original = [
        (138, 74, 112, 255),
        (163, 91, 112, 255),
        (175, 103, 118, 255),
        (189, 117, 126, 255),
        (217, 154, 154, 255),
        (232, 181, 172, 255),
    ]
    mapping = dict(zip(original, colors))
    tree.putdata([mapping.get(pixel, pixel) for pixel in tree.get_flattened_data()])
    return tree


def build_tree_atlas() -> None:
    nature = Image.open(ASSETS / "nature.png").convert("RGBA")
    base = nature.crop((48, 0, 80, 32))
    palettes = [
        ((138, 74, 112, 255), (163, 91, 112, 255), (175, 103, 118, 255), (189, 117, 126, 255), (217, 154, 154, 255), (232, 181, 172, 255)),
        ((144, 98, 93, 255), (170, 121, 89, 255), (196, 154, 108, 255), (220, 185, 138, 255), (232, 207, 166, 255), (246, 226, 177, 255)),
        ((95, 122, 121, 255), (110, 150, 124, 255), (151, 187, 142, 255), (174, 212, 153, 255), (194, 224, 154, 255), (224, 238, 179, 255)),
        ((80, 64, 134, 255), (103, 74, 139, 255), (128, 88, 145, 255), (153, 108, 151, 255), (184, 139, 170, 255), (214, 176, 191, 255)),
    ]
    atlas = Image.new("RGBA", (128, 32))
    for index, palette in enumerate(palettes):
        atlas.alpha_composite(recolor_tree(base, palette), (index * 32, 0))
    atlas.save(ASSETS / "orchard_trees.png")


def build_props() -> None:
    transparent = (0, 0, 0, 0)
    outline = (95, 82, 105, 255)
    shadow = (144, 98, 93, 255)
    wood = (196, 154, 108, 255)
    wood_light = (220, 185, 138, 255)
    cream = (246, 226, 177, 255)
    coral = (189, 117, 126, 255)
    coral_light = (232, 181, 172, 255)
    leaf = (110, 150, 124, 255)
    yellow = (232, 207, 166, 255)
    plum = (128, 88, 145, 255)

    props = Image.new("RGBA", (96, 32), transparent)
    draw = ImageDraw.Draw(props)

    # 48x32 checked blanket with soft corners and tiny fringe.
    draw.rounded_rectangle((1, 3, 46, 28), radius=3, fill=cream, outline=outline)
    for y in range(4, 28, 8):
        for x in range(2, 46, 8):
            if ((x - 2) // 8 + (y - 4) // 8) % 2 == 0:
                draw.rectangle((x, y, min(x + 7, 45), min(y + 7, 27)), fill=coral_light)
    draw.line((2, 11, 45, 11), fill=coral)
    draw.line((2, 19, 45, 19), fill=coral)
    for x in range(4, 45, 8):
        draw.point((x, 30), fill=cream)

    # Basket and fruit tucked into the blanket's lower-right edge.
    draw.rectangle((36, 20, 45, 27), fill=shadow, outline=outline)
    draw.rectangle((37, 21, 44, 26), fill=wood)
    draw.line((38, 23, 43, 23), fill=wood_light)
    draw.arc((37, 16, 44, 24), 180, 360, fill=outline, width=1)
    draw.ellipse((34, 18, 38, 22), fill=coral, outline=outline)
    draw.point((36, 17), fill=leaf)

    # 16x16 harvest crate.
    ox = 48
    draw.rectangle((ox + 1, 6, ox + 14, 14), fill=outline)
    draw.rectangle((ox + 2, 7, ox + 13, 13), fill=wood)
    draw.line((ox + 2, 10, ox + 13, 10), fill=wood_light)
    for x, color in [(3, coral), (7, yellow), (11, plum)]:
        draw.ellipse((ox + x, 4, ox + x + 3, 7), fill=color, outline=outline)
        draw.point((ox + x + 2, 3), fill=leaf)

    # Three 16x16 fallen-fruit clusters.
    for index, color in enumerate((coral, yellow, plum)):
        ox = 64 + index * 16
        draw.ellipse((ox + 3, 9, ox + 7, 13), fill=color, outline=outline)
        draw.ellipse((ox + 9, 7, ox + 13, 11), fill=color, outline=outline)
        draw.point((ox + 6, 8), fill=leaf)
        draw.point((ox + 11, 6), fill=leaf)
        draw.point((ox + 8, 13), fill=shadow)
    props.save(ASSETS / "picnic_grove.png")


if __name__ == "__main__":
    build_tree_atlas()
    build_props()
    print("Prepared orchard tree variants and picnic props.")
