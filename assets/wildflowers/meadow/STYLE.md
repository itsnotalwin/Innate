# INNATE meadow flowers

This is the active meadow atlas: 16 sprites, each 16×16, in a 64×64 sheet.
Columns are apricot orange, butter cream, dusty pink, and powder blue. Rows are
short daisies, low flower clumps, rounded blossoms, and two-bloom bellflowers.

The sprites were adapted with AI-assisted image editing from the imported CC0
flower references, using the existing game's pixel scale and foliage as visual
references. The free packs remain unmodified in the adjacent `btl/` and
`karsiori/` directories, with their original licenses and source hashes.

The edited master is saved in `art/meadow_flowers_master.png`. The offline
converter `tools/prepare_meadow.gd` makes a crisp 16px atlas, removes translucent
edge fringes, and snaps shading to a shared 17-color palette. It adds no runtime
image processing or shader. The flowers render at their native pixel scale.

To rebuild after editing the master:

```sh
godot --headless --path . --script tools/prepare_meadow.gd
python tools/prepare_tiles.py
godot --headless --path . --script tools/build_world.gd
python tools/export_web.py
```

TileSet source 19 includes eight position/flip alternatives per flower so the
carpets can look irregular without creating a node for each small flower.
Composition, quiet space, and color drifts are in `tools/world_layout.json` under
`meadow_design`. Existing roads and open water are excluded from the carpets.
