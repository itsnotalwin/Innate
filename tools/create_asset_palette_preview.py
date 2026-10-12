"""Build a labeled, nearest-neighbor gallery of the map's environment assets."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/planning/full-asset-set.png"
CARDS = [
    ("New tree atlas", "assets/innate/environment_trees.png", "16 leafy, blossom, fruit, and evergreen canopies"),
    ("Mushroom clusters", "assets/innate/mushroom_clusters.png", "16 large colorful woodland groups"),
    ("Flower clumps", "assets/innate/flower_clumps.png", "16 medium bloom clusters"),
    ("Meadow flower details", "assets/innate/meadow_flowers_detail.png", "16 small flower and tuft variants"),
    ("Meadow patch atlas", "assets/innate/meadow_patch_clusters.png", "16 dense patch sprites for continuous color ribbons"),
    ("Woodland props", "assets/innate/woodland_props.png", "16 rocks, reeds, lilies, benches, logs, and trail props"),
    ("Tree and bush source pack", "assets/sprout_lands/foliage/trees_stumps_bushes_v2.png", "retained editor palette"),
    ("Previous generated tree variants", "assets/innate/tree_variants.png", "four earlier custom canopies"),
    ("Original mushroom palette", "assets/sprout_lands/mushroom_variants.png", "small detail mushrooms in six cap colors"),
    ("Meadow flower palette", "assets/wildflowers/meadow/flowers.png", "supporting low flowers and accents"),
    ("Wildflower source atlas", "assets/wildflowers/btl/flowers.png", "100 CC0 flower sprites; see credits"),
    ("Shoreline source plants", "assets/sprout_lands/foliage/pine_water_plants.png", "retained source and editor palette"),
    ("Footbridge", "assets/innate/creek_footbridge.png", "custom bridge landmark used at crossings"),
    ("Cottage landmark", "assets/innate/cottage.png", "custom central home artwork"),
    ("Picnic props", "assets/sprout_lands/picnic_grove.png", "blanket, crate, fruit, and basket props"),
]


def main() -> None:
    width, columns = 1200, 3
    card_width, card_height, gap, margin = 376, 232, 12, 12
    rows = (len(CARDS) + columns - 1) // columns
    height = 78 + rows * (card_height + gap) + margin
    page = Image.new("RGB", (width, height), (241, 239, 218))
    draw = ImageDraw.Draw(page)
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 25)
        head_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
        body_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
    except OSError:
        title_font = head_font = body_font = ImageFont.load_default()
    draw.text((margin, 17), "INNATE — NEW ART DIRECTION ASSET SET", font=title_font, fill=(47, 74, 52))
    for index, (label, relative_path, description) in enumerate(CARDS):
        x = margin + (index % columns) * (card_width + gap)
        y = 66 + (index // columns) * (card_height + gap)
        draw.rounded_rectangle((x, y, x + card_width, y + card_height), radius=8,
                               fill=(250, 249, 237), outline=(190, 200, 162), width=2)
        draw.text((x + 12, y + 10), label, font=head_font, fill=(54, 83, 59))
        draw.text((x + 12, y + 33), description, font=body_font, fill=(86, 101, 75))
        source = Image.open(ROOT / relative_path).convert("RGBA")
        max_width, max_height = card_width - 28, card_height - 103
        scale = min(max_width / source.width, max_height / source.height)
        size = (max(1, round(source.width * scale)), max(1, round(source.height * scale)))
        sprite_sheet = source.resize(size, Image.Resampling.NEAREST)
        target_x = x + (card_width - size[0]) // 2
        target_y = y + 55 + (max_height - size[1]) // 2
        page.paste(sprite_sheet, (target_x, target_y), sprite_sheet)
        dims = f"{source.width}×{source.height} px"
        footer = f"{relative_path}  ·  {dims}"
        while draw.textlength(footer, font=body_font) > card_width - 24:
            footer = footer[:-5] + "…" if not footer.endswith("…") else footer[:-2] + "…"
        draw.text((x + 12, y + card_height - 20), footer, font=body_font, fill=(104, 105, 83))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    page.save(OUTPUT)
    print(f"Wrote {OUTPUT.relative_to(ROOT)} ({width}×{height})")


if __name__ == "__main__":
    main()
