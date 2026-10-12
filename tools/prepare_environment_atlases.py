"""Pack the art-directed 4x4 source sheets into crisp Godot atlases."""
from pathlib import Path
import json

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SHEETS = {
    "environment_trees": ("environment_trees_master.png", 60, "bottom"),
    "mushroom_clusters": ("mushroom_clusters_master.png", 60, "bottom"),
    "flower_clumps": ("flower_clumps_master.png", 54, "bottom"),
    "woodland_props": ("woodland_props_master.png", 54, "bottom"),
    "meadow_flowers_detail": ("meadow_singles_master.png", 56, "bottom"),
    "meadow_patch_clusters": ("meadow_patch_clusters_master.png", 60, "center"),
}
ROW_BOUNDS = {
	"flower_clumps": (0, 415, 700, 986, 1254),
	"meadow_patch_clusters": (0, 415, 700, 986, 1254),
	"meadow_flowers_detail": (0, 375, 625, 940, 1254),
}
CELL = 64
GRID = 4


def opaque_pixel_mask(image: Image.Image) -> Image.Image:
    """Remove transparent-generation fringe and snap sprite edges to hard pixels."""
    alpha = image.getchannel("A")
    return alpha.point(lambda value: 255 if value >= 96 else 0)


def remove_top_cell_bleed(mask: Image.Image) -> Image.Image:
    """Discard short, detached generation debris leaking down from a row above."""
    width, height = mask.size
    rows = [mask.crop((0, y, width, y + 1)).getbbox() is not None for y in range(height)]
    if not rows or not rows[0]:
        return mask
    first_run_end = next((y for y, occupied in enumerate(rows) if not occupied), height)
    next_run_start = next((y for y in range(first_run_end, height) if rows[y]), height)
    short_top_fragment = first_run_end <= int(height * 0.14)
    clear_gap = next_run_start - first_run_end >= max(6, int(height * 0.025))
    if short_top_fragment and clear_gap:
        mask.paste(0, (0, 0, width, first_run_end))
    return mask


def shared_environment_palette(atlas_paths: list[Path], flower_reference: Path, colors: int = 80) -> tuple[Image.Image, list[tuple[int, int, int]]]:
    """Build one palette for the environment family while retaining flower colors."""
    visible: list[tuple[int, int, int]] = []
    for path in atlas_paths:
        image = Image.open(path).convert("RGBA")
        visible.extend(pixel[:3] for pixel in image.get_flattened_data() if pixel[3] >= 96)
    swatch = Image.new("RGB", (len(visible), 1))
    swatch.putdata(visible)
    quantized = swatch.quantize(colors=colors, method=Image.Quantize.MEDIANCUT)
    learned = quantized.getpalette()[: colors * 3]

    reference = Image.open(flower_reference).convert("RGBA")
    flower_colors = sorted({pixel[:3] for pixel in reference.get_flattened_data() if pixel[3] >= 96})
    colors_rgb = [tuple(learned[index:index + 3]) for index in range(0, len(learned), 3)]
    colors_rgb.extend(color for color in flower_colors if color not in colors_rgb)
    flattened = [component for color in colors_rgb[:256] for component in color]
    flattened.extend([0] * (768 - len(flattened)))
    palette = Image.new("P", (1, 1))
    palette.putpalette(flattened)
    return palette, colors_rgb[:256]


def apply_palette(image: Image.Image, palette: Image.Image) -> Image.Image:
    """Map visible RGB pixels to the shared environment palette without changing alpha."""
    image = image.convert("RGBA")
    alpha = image.getchannel("A")
    quantized = image.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE)
    result = quantized.convert("RGB").convert("RGBA")
    result.putalpha(alpha)
    return result


def pack_sheet(source_path: Path, destination_path: Path, maximum: int, anchor: str, row_bounds: tuple[int, ...] | None = None) -> None:
    source = Image.open(source_path).convert("RGBA")
    atlas = Image.new("RGBA", (GRID * CELL, GRID * CELL), (0, 0, 0, 0))
    cell_width = source.width // GRID
    if row_bounds is None:
        row_bounds = tuple(round(row * source.height / GRID) for row in range(GRID + 1))

    for row in range(GRID):
        for column in range(GRID):
            left, top = column * cell_width, row_bounds[row]
            right = source.width if column == GRID - 1 else (column + 1) * cell_width
            bottom = row_bounds[row + 1]
            sprite = source.crop((left, top, right, bottom))
            mask = opaque_pixel_mask(sprite)
            mask = remove_top_cell_bleed(mask)
            bounds = mask.getbbox()
            if bounds is None:
                raise ValueError(f"No visible sprite in {source_path.name}, row {row}, column {column}")
            sprite.putalpha(mask)
            sprite = sprite.crop(bounds)
            sprite.thumbnail((maximum, maximum), Image.Resampling.NEAREST)
            x = column * CELL + (CELL - sprite.width) // 2
            y = row * CELL + (CELL - sprite.height if anchor == "bottom" else (CELL - sprite.height) // 2)
            atlas.alpha_composite(sprite, (x, y))

    destination_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(destination_path)


def main() -> None:
    source_root = ROOT / "art"
    destination_root = ROOT / "assets/innate"
    for name, (master, maximum, anchor) in SHEETS.items():
        output = destination_root / f"{name}.png"
        pack_sheet(source_root / master, output, maximum, anchor, ROW_BOUNDS.get(name))
    shared_palette, palette_colors = shared_environment_palette(
        [destination_root / f"{name}.png" for name in SHEETS] + [ROOT / "art/meadow_flowers_master.png"],
        ROOT / "assets/wildflowers/meadow/flowers.png",
    )
    (destination_root / "environment_palette.json").write_text(
        json.dumps(["#%02x%02x%02x" % color for color in palette_colors], indent=2) + "\n"
    )
    for name in SHEETS:
        output = destination_root / f"{name}.png"
        apply_palette(Image.open(output), shared_palette).save(output)
        print(f"Matched {output.relative_to(ROOT)} to the shared environment palette")
    for name, (master, _, _) in SHEETS.items():
        print(f"Wrote {name}.png (16 sprites, 64px atlas cells)")


if __name__ == "__main__":
    main()
