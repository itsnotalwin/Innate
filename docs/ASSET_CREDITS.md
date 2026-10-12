# Asset credits and licensing

The picnic blanket, basket, crate, fallen fruit, and flowering cottage trellis were created or refined with AI-assisted image generation during the asset style pass. The picnic-prop source master is `art/picnic_props_master.png`; `tools/prepare_picnic.gd` converts it into native pixel cells using the original nature sheet's opaque colors. The trellis source master is `art/cottage_trellis_master.png`; it is palette-mapped into `assets/innate/cottage_trellis.png`. The cottage and footbridges are original project artwork. The current art direction adds original AI-assisted environment sprite families, prepared as deterministic nearest-filtered atlases by `tools/prepare_environment_atlases.py`. This includes the flower meadow sheets in `art/meadow_singles_master.png` and `art/meadow_patch_clusters_master.png`, as well as the tree, mushroom, flower-clump, and woodland-prop masters. These are project-specific additions, not an expansion for standalone redistribution. Original source packs and their terms remain unchanged.

**Sprout Lands — Assets by Cup Nooble**

Official source: https://cupnooble.itch.io/sprout-lands-asset-pack

The free Basic Pack was acquired through the official itch.io free-download flow on 9 October 2026 (Africa/Johannesburg). Download listing: `Sprout Lands - Sprites - Basic pack.zip`, official upload ID `15327222`, listed update 23 October 2025. Cup Nooble’s free `Sprout Lands - Free Gift - “sorry for the delay”` pack was acquired through its no-payment download option on 11 October 2026. Its relevant foliage atlases are integrated into the editable palette and map: pine, birch, cherry blossom, mixed trees and bushes, shoreline plants, and farming plants. Non-foliage areas of that pack (winter, dungeon, ocean, village, and furniture) are outside this visual update. Mushroom variants are recolored directly from the original Basic Pack sprites, preserving their pixels and silhouette. The Free Gift pack’s unmodified `read_me.txt` is preserved as `assets/sprout_lands/FREE_GIFT_LICENSE.txt` and carries the same Basic Pack non-commercial terms and credit requirement.

## Applicable artwork terms

The complete, unmodified included `read_me.txt` is preserved as `assets/sprout_lands/LICENSE.txt`. It says:

> You can use these assets in any kind of non-commercial projects.
>
> Except anything to do with NFTs or AI training is not allowed.
>
> You can not redistribute the asset pack itself or resell it on other platforms, even if it is slightly modified.
>
> Of course, you can redistribute your own projects made with these assets like games, software, or other.
>
> Making your project opensource is also allowed.
>
> For open source projects include a note that says some or all assets are made by Cup Nooble together with the licensing terms.
>
> Credit is required : (Cup Nooble).

The official landing page also has older, more generally worded no-redistribution text. This delivery relies on the explicit game/open-source project permission in the updated licenses included with the legitimately downloaded packs. The assets are included only as selected components of INNATE, with credits and their full terms; this is not a standalone asset-pack release. The repository is private and the playable non-commercial game is deployed through GitHub Pages. Preserve both licenses and credits when sharing the game. Commercial use needs separate permission or the appropriate paid license.

## Integrated sheets

| Local file | Original Basic Pack file | Dimensions | Use |
| --- | --- | --- | --- |
| grass.png | Tilesets/Grass.png | 176×112 | 16px terrain, shoreline, grass variation |
| water.png | Tilesets/Water.png | 64×16 | Pond surface |
| dirt.png | Tilesets/Tilled Dirt.png | 128×128 | Paths and decorative garden soil |
| fences.png | Tilesets/Fences.png | 64×64 | Garden fence |
| house.png | Tilesets/Wooden House.png | 112×80 | Cottage, windows, door, roof, step |
| nature.png | Objects/Basic Grass Biom things 1.png | 144×80 | Starter trees, bushes, rocks, flowers, mushrooms, logs, stumps |
| pine_biome.png | Free Gift / Plant update 2 / Pine Tree Biome.png | 160×64 | Pine trees and accents |
| foliage/trees_stumps_bushes_v2.png | Free Gift / Plant update 2 / Trees, stumps and bushes v2.png | 192×128 | Large leafy trees, fruiting trees, bushes, stumps |
| foliage/birch_biome.png | Free Gift / Plant update 2 / Birch wood Biom.png | 160×64 | Birch tree shapes |
| foliage/cherry_blossom_biome.png | Free Gift / Plant update 2 / Cherry Blossom Biom.png | 160×80 | Pink blossom tree shapes |
| foliage/*_water_plants.png | Free Gift / Plant update 2 / * water plants.png | 96–144×32 | Seasonal shoreline plants |
| foliage/farming_plants_v2.png | Free Gift / Plant update 2 / Farming Plants v2.png | 112×528 | Extra crop and flower variety for the palette |
| foliage/farming_plants_v2_watered.png | Free Gift / Plant update 2 / Farming Plants v2 watered.png | 112×528 | Watered growth-stage variation for the palette |
| items/wood_and_mushroom_items.png | Free Gift / Plant update 2 / wood n shroms.png | 96×80 | Wood and mushroom item sprites available in the palette; not used as environmental mushrooms |
| mushroom_variants.png | Derived from Objects/Basic Grass Biom things 1.png | 48×96 | Original mushroom caps in six gentle colorways; stems and pixel shapes preserved |
| plants.png | Objects/Basic Plants.png | 96×32 | Decorative plants |
| character.png | Characters/Basic Charakter Spritesheet.png | 192×192 | One playable character; 48×48 frames |
| creek_reeds.png | Original INNATE pixel art | 16×24 | Small creek-edge reeds drawn to match the Basic Pack palette and pixel scale |
| pond_life.png | Original INNATE pixel art | 64×48 | Three tiny four-frame dragonflies drawn in the existing soft foliage palette |
| `environment_trees.png` | Original INNATE artwork | 256×256 (16 × 64px cells) | Bright layered canopies, blossoms, fruit, and evergreens across the complete map |
| `mushroom_clusters.png` | Original INNATE artwork | 256×256 (16 × 64px cells) | Large coordinated mushroom clusters in the western woodland destination |
| `flower_clumps.png` | Original INNATE artwork; mapped to the shared environment palette | 256×256 (16 × 64px cells) | Dense multi-flower drifts for small destination accents |
| `meadow_flowers_detail.png` | Original INNATE artwork; mapped to the shared environment palette | 256×256 (16 × 64px cells) | Standalone flower silhouettes for larger accents |
| `meadow_patch_clusters.png` | Original INNATE artwork; mapped to the shared environment palette | 256×256 (16 × 64px cells) | Irregular low flower patches for natural meadow drifts |
| `woodland_props.png` | Original INNATE artwork | 256×256 (16 × 64px cells) | Rocks, reeds, lily groups, seating, fallen timber, stump, and signpost |

The downloaded Basic Pack and selected Free Gift sheets remain complete, unmodified source atlases in the editor TileSet palette. The current map uses the coordinated original INNATE canopy, mushroom, flower, and woodland-prop atlases for its main environment art; the downloaded palettes remain available for later areas and fine accents. The outlined item sprites remain available in the palette but are not used as environmental mushrooms. The mushroom-color sheet is derived from the Basic Pack atlas by recoloring cap pixels only. The project preserves nearest filtering. Character rows are down, up, right, left. Columns 0–1 are available idle frames, columns 2–3 are walking; this game uses a stationary column-0 idle and both walk frames. It does not use the separate action sheet.

## Wildflower packs

Two free CC0 flower packs were acquired through their official itch.io download flows on 11 October 2026 and retained as source references and editable palette assets:

| Creator and official source | Imported artwork | Use |
| --- | --- | --- |
| [BTL games — Pixel art fauna asset pack](https://btl-games.itch.io/pixel-art-fauna-asset-pack) | 100 original 16×16 flora sprites; upload ID 3216074 | Small orange, gold, pink, blue, violet, and white flowers in loose meadow drifts. Fruit trees and other non-flower sprites are available in the palette but are not placed in the meadow. |
| [karsiori — FREE Pixel Art Flower Pack](https://karsiori.itch.io/free-pixel-art-flower-pack) | 13 flower designs in their available color variants; upload ID 9464396 | Daisy clumps, bell-shaped blooms, orange and yellow flowers, and taller violet accents. Pots and bushes are excluded. |

Both creators list Creative Commons Zero v1.0 Universal on their official pages, allowing use, modification, and redistribution. Their credits and source links are retained in `assets/wildflowers/LICENSE.txt`. The atlas packing script preserves the original pixels; `assets/wildflowers/catalog.json` records original PNG hashes, dimensions, and positions. These assets have their own CC0 terms and do not change the license of Cup Nooble's artwork.

Both original sheets remain in the editable TileSet as sources 17 and 18, but are not placed in the map. The redesigned native 16px flowers in source 19 paint the meadow, cottage beds, and roadside scatter. The 64px patch atlas in source 25 supplies larger low drifts, while the coordinated flower accents use the same environment palette. The generated master and conversion workflow are retained in `art/meadow_flowers_master.png`, `tools/prepare_meadow.gd`, and `assets/wildflowers/meadow/STYLE.md`. The original CC0 sheets remain unchanged.

Position and flip alternatives scatter the low flowers within their cells. Larger accents share the same palette and Y sorting. Flower carpets exclude paths and open water, and a small grassy center remains open. The meadow loop has continuous corners, and the southern tree border is spaced more loosely around this clearing. The cottage garden now uses the native flower tiles rather than the original pack's crop sprites.

## Visual references

[Slumbering Woods](https://www.chunkyquail.com/slumbering-woods/) and [Fugi](https://melollo.itch.io/fugi) informed the way tree masses frame a mushroom clearing, and how mushroom colors can vary while a woodland palette stays cohesive. These are composition and color references only; no external game art is used.

## Godot integration

[Maaack/Sprout-Lands-Tilemap](https://github.com/Maaack/Sprout-Lands-Tilemap) was inspected, including README, base native TileMapLayer scene, example scenes, artwork license, and MIT code license. Its Godot 4.3 resource format is compatible with 4.6.3, but its older grass sheet differs from the current Basic Pack. INNATE therefore uses a fresh native TileSet for the current grass sheet and adapts the compatible dirt terrain peering configuration into `tools/dirt_terrain.json`. No plugin or demonstration map is installed or copied.

Copyright (c) 2024-present Marek Belski. The MIT notice is retained in `docs/MAAACK_LICENSE.txt`. Upstream revision: `47ddc077797d504b77ca96d602428e2ba3ba21f5`. Artwork retains Cup Nooble's separate terms.

## Dependencies

Godot Engine: Juan Linietsky, Ariel Manzur, and contributors, MIT; https://godotengine.org/license/. Its MIT notice is included in `docs/GODOT_LICENSE.txt`. Runtime uses built-in Godot nodes and its generated Web runtime. The HTML shell derives from the matching Godot Web template. Python, Pillow, Playwright, and Chromium are development/testing tools, not shipped game dependencies.

The portrait update also uses the same Basic Pack character sheet on its loading screen (`docs/loader-character.png`). The required Cup Nooble credit is displayed on that screen and preserved here. Gameplay retains only the requested countdown and mobile touch control; the attribution remains on the loader and in this document.

The pond garden uses the included water-plant sheets for lily pads, flowering lilies, and shoreline reeds. Three original animated dragonflies add subtle motion above the water. A narrow walking loop reaches a log viewpoint on the east bank while leaving the pond collision and main movement routes intact.
