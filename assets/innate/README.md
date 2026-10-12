# INNATE environment art

The current art direction uses a bright, richly layered top-down pixel landscape: luminous spring grass, warm winding paths, rounded canopy masses, clear feature silhouettes, and colorful destination pockets. Six generated master sheets add 96 reusable environment sprites, alongside the native 16-sprite flower tile sheet:

- `environment_trees.png`: 16 layered leafy, blossom, fruit, and evergreen canopies.
- `mushroom_clusters.png`: 16 varied mushroom groups in coordinated warm and cool cap colors.
- `flower_clumps.png`: 16 dense but readable flower drifts across pink, violet, gold, cream, and blue palettes.
- `meadow_flowers_detail.png`: 16 standalone flower silhouettes for taller accents and fine coverage.
- `meadow_patch_clusters.png`: 16 irregular low flower drifts for building broad, natural meadow patches.
- `woodland_props.png`: 16 rocks, reeds, lily-pad groups, benches, a log, a stump, and a signpost.

Each 256×256 atlas has sixteen 64×64 cells. These six atlases and the active 64×64 native flower tile sheet share a palette built from the tree, mushroom, flower, and prop families. This ties the larger foliage and props to the small meadow flowers while retaining their separate silhouettes. Original masters are stored in `art/`; `tools/prepare_environment_atlases.py` builds the palette, removes detached generation bleed, and packs the sprite cells. `tools/prepare_meadow.gd` uses that same palette for the native flowers. Their TileSet sources are 19–25. Runtime sprites use nearest-neighbor filtering.

The first map routes trees, low shrubs, mushrooms, rocks, reeds, benches, logs, stumps, meadow drifts, garden beds, and roadside details through this custom foliage family. The old small mushroom, shrub, log, stump, and crop sprites remain in the source asset pack, but are no longer mixed into those placements.

Rebuild the coordinated atlas family and Pages output in this order:

```sh
python tools/prepare_environment_atlases.py
godot --headless --path . --script tools/prepare_meadow.gd
python tools/prepare_tiles.py
python tools/prepare_cottage_trellis.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script tools/build_world.gd
python tools/export_web.py
```

Other custom landmarks include `cottage.png`, `cottage_trellis.png`, and `creek_footbridge.png`. The trellis is palette-mapped and placed at the cottage garden's east bed. The older `tree_variants.png` is retained as project artwork but the first map now uses the larger 16-variant canopy atlas. Original downloaded packs remain unchanged and their terms are listed in `docs/ASSET_CREDITS.md`.
