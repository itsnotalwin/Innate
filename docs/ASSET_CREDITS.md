# Asset credits and licensing

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

The eight selected Basic Pack sheets, selected Free Gift foliage sheets, and wood/mushroom item sheet are kept as complete, unmodified source atlases, apart from normalized local filenames. They are available in the editor TileSet palette; trees are also placed as whole sprites so their crowns and trunks stay together. The outlined item sprites remain available in the palette but are not used as environmental mushrooms. The mushroom-color sheet is derived from the Basic Pack atlas by recoloring cap pixels only. The project preserves nearest filtering. Character rows are down, up, right, left. Columns 0–1 are available idle frames, columns 2–3 are walking; this game uses a stationary column-0 idle and both walk frames. It does not use the separate action sheet.

## Visual references

[Slumbering Woods](https://www.chunkyquail.com/slumbering-woods/) and [Fugi](https://melollo.itch.io/fugi) informed the way tree masses frame a mushroom clearing, and how mushroom colors can vary while a woodland palette stays cohesive. These are composition and color references only; no external game art is used.

## Godot integration

[Maaack/Sprout-Lands-Tilemap](https://github.com/Maaack/Sprout-Lands-Tilemap) was inspected, including README, base native TileMapLayer scene, example scenes, artwork license, and MIT code license. Its Godot 4.3 resource format is compatible with 4.6.3, but its older grass sheet differs from the current Basic Pack. INNATE therefore uses a fresh native TileSet for the current grass sheet and adapts the compatible dirt terrain peering configuration into `tools/dirt_terrain.json`. No plugin or demonstration map is installed or copied.

Copyright (c) 2024-present Marek Belski. The MIT notice is retained in `docs/MAAACK_LICENSE.txt`. Upstream revision: `47ddc077797d504b77ca96d602428e2ba3ba21f5`. Artwork retains Cup Nooble's separate terms.

## Dependencies

Godot Engine: Juan Linietsky, Ariel Manzur, and contributors, MIT; https://godotengine.org/license/. Its MIT notice is included in `docs/GODOT_LICENSE.txt`. Runtime uses built-in Godot nodes and its generated Web runtime. The HTML shell derives from the matching Godot Web template. Python, Pillow, Playwright, and Chromium are development/testing tools, not shipped game dependencies.

The portrait update also uses the same Basic Pack character sheet on its loading screen (`docs/loader-character.png`). The required Cup Nooble credit is displayed on that screen and preserved here. Gameplay retains only the requested countdown and mobile touch control; the attribution remains on the loader and in this document.
