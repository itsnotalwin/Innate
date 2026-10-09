# Asset credits and licensing

**Sprout Lands — Assets by Cup Nooble**

Official source: https://cupnooble.itch.io/sprout-lands-asset-pack

The free Basic Pack was acquired through the official itch.io free-download flow on 9 October 2026 (Africa/Johannesburg). Download listing: `Sprout Lands - Sprites - Basic pack.zip`, official upload ID `15327222`, listed update 23 October 2025. No premium-only files, animals, action animations, tools, or unrelated artwork are integrated.

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

The official landing page also has older, more generally worded no-redistribution text. This delivery relies on the explicit game/open-source project permission in the updated license included with the legitimately downloaded Basic Pack. The assets are included only as selected components of INNATE, with credits and their full terms; this is not a standalone asset-pack release. The connected repository was verified **private**, and no public deployment or release was made. Preserve the license and credits when sharing this non-commercial game. Commercial use needs separate permission or the appropriate paid license.

## Integrated sheets

| Local file | Original Basic Pack file | Dimensions | Use |
| --- | --- | --- | --- |
| grass.png | Tilesets/Grass.png | 176×112 | 16px terrain, shoreline, grass variation |
| water.png | Tilesets/Water.png | 64×16 | Pond surface |
| dirt.png | Tilesets/Tilled Dirt.png | 128×128 | Paths and decorative garden soil |
| fences.png | Tilesets/Fences.png | 64×64 | Garden fence |
| house.png | Tilesets/Wooden House.png | 112×80 | Cottage, windows, door, roof, step |
| nature.png | Objects/Basic Grass Biom things 1.png | 144×80 | Trees, bushes, rocks, flowers, mushrooms, logs, stumps |
| plants.png | Objects/Basic Plants.png | 96×32 | Decorative plants |
| character.png | Characters/Basic Charakter Spritesheet.png | 192×192 | One playable character; 48×48 frames |

Artwork is unchanged, only filenames are normalized. The project preserves native sprite/tile scale and uses nearest filtering. Character rows are down, up, right, left. Columns 0–1 are available idle frames, columns 2–3 are walking; this game uses a stationary column-0 idle and both walk frames. It does not use the separate action sheet.

## Godot integration

[Maaack/Sprout-Lands-Tilemap](https://github.com/Maaack/Sprout-Lands-Tilemap) was inspected, including README, base native TileMapLayer scene, example scenes, artwork license, and MIT code license. Its Godot 4.3 resource format is compatible with 4.6.3, but its older grass sheet differs from the current Basic Pack. INNATE therefore uses a fresh native TileSet for the current grass sheet and adapts the compatible dirt terrain peering configuration into `tools/dirt_terrain.json`. No plugin or demonstration map is installed or copied.

Copyright (c) 2024-present Marek Belski. The MIT notice is retained in `docs/MAAACK_LICENSE.txt`. Upstream revision: `47ddc077797d504b77ca96d602428e2ba3ba21f5`. Artwork retains Cup Nooble's separate terms.

## Dependencies

Godot Engine: Juan Linietsky, Ariel Manzur, and contributors, MIT; https://godotengine.org/license/. Its MIT notice is included in `docs/GODOT_LICENSE.txt`. Runtime uses built-in Godot nodes and its generated Web runtime. The HTML shell derives from the matching Godot Web template. Python, Pillow, Playwright, and Chromium are development/testing tools, not shipped game dependencies.

The portrait update also uses the same Basic Pack character sheet on its loading screen (`docs/loader-character.png`). The required Cup Nooble credit is displayed on that screen and preserved here; gameplay text overlays were removed.
