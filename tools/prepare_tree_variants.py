"""Pack the four generated large tree variants into native 64px atlas cells."""
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/tree_variants_master.png"
DESTINATION = ROOT / "assets/innate/tree_variants.png"


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    middle_x, middle_y = source.width // 2, source.height // 2
    quadrants = [
        (0, 0, middle_x, middle_y),
        (middle_x, 0, source.width, middle_y),
        (0, middle_y, middle_x, source.height),
        (middle_x, middle_y, source.width, source.height),
    ]
    atlas = Image.new("RGBA", (4 * 64, 64), (0, 0, 0, 0))
    for index, bounds in enumerate(quadrants):
        sprite = source.crop(bounds)
        # Ignore low-alpha generation fringe around the transparent background.
        alpha_mask = sprite.getchannel("A").point(lambda alpha: 255 if alpha > 64 else 0)
        sprite = sprite.crop(alpha_mask.getbbox())
        sprite.thumbnail((48, 48), Image.Resampling.NEAREST)
        atlas.alpha_composite(sprite, (index * 64 + (64 - sprite.width) // 2, 64 - sprite.height))
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(DESTINATION)
    print(f"Wrote {DESTINATION.relative_to(ROOT)} ({atlas.width}x{atlas.height}, 4 x 48px sprites in 64px cells)")


if __name__ == "__main__":
    main()
