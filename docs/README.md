# Playing and editing INNATE

INNATE is a non-commercial exploration gift for Paige. Milestone 01 uses Godot **4.6.3 Standard**, GDScript, and the Compatibility renderer. There are no combat, farming, inventory, NPC, quest, or save systems.

## Windows

1. Download the delivery ZIP and extract its contents into `C:\Users\Operations 3\Desktop\GAMES\Innate`, or check out the task branch with Git.
2. In Godot 4.6.3 Standard, import the `project.godot` directly inside that directory. Allow Godot to import the textures.
3. Press **F5**. The main scene is `scenes/main.tscn`.
4. Walk with **WASD** or **arrow keys**, including simultaneous keys for diagonal movement. Release to stop. On a touch-capable browser, drag the joystick at bottom-left. Landscape is recommended; portrait displays a rotation hint.

Older Godot versions are not verified. Godot 4.3 supports TileMapLayer, but use the tested 4.6.3 release and matching export templates for reproducibility.

## Editing

Open `scenes/world.tscn`. Terrain, paths, water, ground details, and garden plants are native editable **TileMapLayer** nodes using `resources/tilesets/sprout_lands.tres`. The `Nature` parent sorts the player, trees, bushes, rocks, cottage, and fence segments by their foot Y coordinates. Objects have explicit editable positions and small physical footprints. Change walking speed on the player instance or in `scenes/player.tscn`.

The scene is saved; nothing generates the map at runtime. `tools/world_layout.json` preserves curated placements and routes. `tools/build_world.gd` is an optional offline scene generator and **overwrites world.tscn**, so save editor changes before regenerating it. `tools/prepare_tiles.py` rebuilds atlas definitions and needs Pillow. `tools/dirt_terrain.json` contains the compatible MIT-licensed dirt terrain configuration adapted from Maaack.

## Web export

In Godot, install the **4.6.3 matching export templates** if absent, then use **Project → Export → Web → Export Project**. Select `build/web/index.html`. The preset uses single-threaded WebGL 2 Compatibility and does not require SharedArrayBuffer/COOP/COEP headers.

Command line, from the project directory:

```sh
python tools/export_web.py --godot /path/to/Godot
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

If Godot is on PATH, omit `--godot`. On Windows, pass the full quoted executable path, for example `python tools/export_web.py --godot "C:\Tools\Godot_v4.6.3-stable_win64.exe"`.

Open **http://127.0.0.1:8000/** in a modern WebGL 2 browser. Opening `index.html` using `file://` is not supported. Keep every generated file beside the entry point. The delivery ZIP includes the tested Web build. Build outputs are excluded from Git and Godot import by `.gitignore` and `build/.gdignore`.

## Verification

A small native integration check exercises the real saved scene and controller:

```sh
godot --headless --path . --fixed-fps 60 --script tests/verify_game.gd
```

In the configured cloud environment, prefix Godot commands with `XDG_DATA_HOME=/workspace/.godot/data XDG_CONFIG_HOME=/workspace/.godot/config XDG_CACHE_HOME=/workspace/.godot/cache`. Windows uses its normal Godot directories.

With the HTTP server running and Python Playwright/Pillow plus Chromium installed:

```sh
python tests/verify_browser.py
```

The browser script uses `/usr/bin/chromium`; adjust that path for another installation. It checks rendered movement, release/cancellation, resizing, console errors, and desktop/mobile layouts. Mobile testing is browser emulation, not a real phone. Evidence is in `tests/evidence/`, excluded from Godot import.

## Files

- `scenes/`: main, world, player, mobile controls.
- `scripts/`: shared player movement, joystick, UI resize/orientation handling.
- `assets/sprout_lands/`: eight selected original Basic Pack sheets and their license.
- `resources/tilesets/`: native atlases and terrain/collision definitions.
- `tools/`: optional offline generation, local ZIP import, export helper, browser shell.
- `build/web/`: genuine generated Godot HTML/JS/WASM/PCK output.
- `tests/evidence/`: actual running-game screenshots and verification results.
- `docs/`: credits, licenses, instructions, and build report.

To restore artwork, download the free Basic Pack directly from Cup Nooble and run `python tools/import_assets.py "path/to/Sprout Lands - Sprites - Basic pack.zip"`. The importer only extracts sheets used in this game. It does not download premium assets or replace the world.
