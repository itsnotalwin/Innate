# INNATE meadow flowers

This is the active meadow atlas: 16 sprites, each 16×16, in a 64×64 sheet.
Columns are apricot orange, butter cream, dusty pink, and powder blue. Rows are
short daisies, low flower clumps, rounded blossoms, and bellflower sprigs.

The sprite master was redrawn with the project's detailed woodland pixel art as
its style reference, then packed at native resolution. It shares the palette
used by the custom trees, mushrooms, patch clusters, and woodland props. The
free packs remain unmodified in the adjacent `btl/` and `karsiori/` directories,
with their original licenses and source hashes.

The master is saved in `art/meadow_flowers_master.png`. Build the common foliage
palette and larger atlases first with `tools/prepare_environment_atlases.py`,
then run `tools/prepare_meadow.gd` to pack the 16px flower sheet at native scale.
The game adds no runtime image processing or shader.

To rebuild after editing the master:

```sh
python tools/prepare_environment_atlases.py
godot --headless --path . --script tools/prepare_meadow.gd
python tools/prepare_tiles.py
godot --headless --path . --script tools/build_world.gd
python tools/export_web.py
```

TileSet source 19 includes eight position/flip alternatives per flower so the
carpets can look irregular without creating a node for each small flower.
Composition, quiet space, and color drifts are in `tools/world_layout.json` under
`meadow_design`. Existing roads and open water are excluded from the carpets.
