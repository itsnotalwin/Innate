# INNATE first-map asset catalog

This catalog tracks the complete environment palette used for the expanded first map and where each family appears. The map target is a bright, dense top-down pixel-art woodland with a warm cottage, winding sand paths, flowering clearings, ponds, bridges, and a picnic orchard.

## Scene palette

| Map element | Assets | Source and current use |
| --- | --- | --- |
| Ground and roads | `assets/sprout_lands/grass.png`, `dirt.png` | Cup Nooble Basic Pack; native 16px terrain, varied grass, and continuous warm sand routes. |
| Water and banks | `water.png`, `assets/innate/woodland_props.png`, `pond_life.png` | Animated pond and full-height river, with custom reeds, lily groups, stones, and dragonflies. |
| Trees | `assets/innate/environment_trees.png` | 16 new canopies, including broad leafy, tall, pink-blossomed, fruiting, evergreen, and accent silhouettes. Used across boundaries, grove, approaches, and orchard. |
| Mushrooms | `assets/innate/mushroom_clusters.png` | Sixteen cap and cluster variants are used for both large destination groups and smaller roadside mushrooms. |
| Flowers and ground foliage | `assets/wildflowers/meadow/flowers.png`, `assets/innate/meadow_patch_clusters.png`, `meadow_flowers_detail.png` | Native 16px flowers paint the meadow ribbons, garden beds, and roadside scatter; detailed low patch sprites create broad drifts, and taller individual blooms mark clearings. |
| Woodland props | `assets/innate/woodland_props.png` | 16 rocks, reed clumps, lily-pad groups, benches, fallen log, stump, and trail marker; reused across river, pond, clearings, and paths. |
| Cottage and crossings | `innate/cottage.png`, `innate/cottage_trellis.png`, `innate/creek_footbridge.png`, `house.png` | Custom central home landmark, flowering garden trellis, and two bridge crossings, with unmodified source house sheet retained in the palette. |
| Cottage garden and orchard | `fences.png`, `assets/innate/meadow_patch_clusters.png`, `picnic_grove.png`, `environment_trees.png`, `woodland_props.png` | Centered walk-through gates, grass between cohesive flower beds, a trellis, shaded bench, picnic blanket and crate, fallen fruit, and matching fruiting canopies. |
| Character | `character.png` | Cup Nooble Basic Pack character sheet used by the playable character and mobile-focused game. |

## Art-direction rules

- Match the provided map reference: bright lime spring ground, creamy winding paths, layered round tree crowns with dappled light, saturated flower drifts, warm wood, clear turquoise water, and distinct destination silhouettes.
- Use readable pixel clusters and nearest-neighbor filtering. The terrain stays on a 16px grid; the generated art uses 64px atlas cells so larger sprites can layer across the grid.
- Keep the native flower atlas and all six larger environment atlases cohesive with one shared palette built from trees, mushrooms, flowers, and props.
- Build destinations from reusable atlas pieces. Keep routes visually clear and leave breathing space around landmarks, while surrounding them with smaller accents and ground detail.
- New art is original project artwork generated for this direction. Downloaded packs remain unchanged and available as source/editor palettes; the first-map environment is moving to the coordinated custom atlases.

## Rebuild and inspect

```sh
python tools/prepare_environment_atlases.py
godot --headless --path . --script tools/prepare_meadow.gd
python tools/prepare_tiles.py
python tools/prepare_cottage_trellis.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script tools/build_world.gd
python tools/export_web.py
```

The Godot TileSet exposes the native flower sheet and six 16-sprite atlases as sources 19–25. `assets/innate/README.md` describes the custom assets; map placements are authored in `tools/build_world.gd` and `tools/world_layout.json`.
