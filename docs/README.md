# Playing and editing INNATE

INNATE is a non-commercial exploration gift for Paige. Milestone 01 uses Godot **4.6.3 Standard**, GDScript, and the Compatibility renderer. There are no combat, farming, inventory, NPC, quest, or save systems.

## Windows

1. Download the delivery ZIP and extract its contents into `C:\Users\Operations 3\Desktop\GAMES\Innate`, or check out the task branch with Git.
2. In Godot 4.6.3 Standard, import the `project.godot` directly inside that directory. Allow Godot to import the textures.
3. Press **F5**. The main scene is `scenes/main.tscn`.
4. Walk with **WASD** or **arrow keys**, including simultaneous keys for diagonal movement. Release to stop. On a touch-capable browser, drag the joystick at bottom-left. Portrait is the primary phone layout and fills the available screen. Landscape and desktop adapt automatically.

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

With Python Playwright/Pillow plus Chromium installed (the test starts its own local HTTP server):

```sh
python tests/verify_browser.py
```

The browser script uses `/usr/bin/chromium`; adjust that path for another installation. Set `INNATE_TEST_URL` to test another served build. It checks rendered movement, release/cancellation, resizing, console errors, and desktop/mobile layouts. Mobile testing is browser emulation, not a real phone. Evidence is in `tests/evidence/`, excluded from Godot import.

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

## Deploying from GitHub Pages

The repository's `docs/` folder contains the tested HTML, JavaScript, WASM, PCK, splash image, and audio worklets, plus `.nojekyll`. These are real Godot export files. `docs/.gdignore` prevents Godot from importing deployment artifacts back into the game.

Open GitHub **Settings → Pages → Build and deployment**:

1. Source: **Deploy from a branch**.
2. Branch: **codex/innate-milestone-01**.
3. Folder: **/ (root)** or **/docs**.
4. Click **Save** and wait for the Pages deployment to finish.

The expected URL is `https://itsnotalwin.github.io/Innate/`; use the URL shown in Settings after deployment. The connected GitHub integration lacks Pages-management access (HTTP 403), so this setting must be enabled in GitHub. Private-repository Pages requires a supporting GitHub plan. No repository visibility change is made automatically.

The export helper mirrors future exports into `docs/`. Run `python tools/check_web_build.py`, then commit and push the generated root `index.html`, `docs/game-*.pck`, `docs/index*`, `docs/loader-character.png`, and `docs/build-manifest.json` files to update the deployed game. All runtime paths are relative and work under the `/Innate/` project prefix.

Root-folder Pages hosting is supported through the root Godot export HTML shell with `<base href="./docs/">`. It runs the same genuine game, loading its JS, WASM, PCK, splash, and worklets from `docs/`. No redirect or substitute game is used.

## Portrait presentation and smooth movement

The default logical view is 216×384 in portrait and 384×216 in landscape, expanded to fill the screen. Ultrawide views are capped to the map dimensions. Canvas-items rendering, nearest texture filtering, physics interpolation, and physics-tick camera smoothing preserve the artwork while allowing finer camera movement. The Web canvas has a maximum 720px render edge to bound GPU work independently of phone pixel density. The CSS display still fills the screen. Safe-area padding keeps the joystick away from home indicators.

The custom loader replaces the Godot splash and disappears after the first actual game frame. Credits are on that loader and in the repository documentation. Only the joystick appears over gameplay on touch devices.

## Export integrity

The export helper requires the matching Godot version and stops if Godot logs an error, even if its process returns zero. The generated manifest records source fingerprints, file hashes, byte sizes, and the active game pack. `python tools/check_web_build.py` detects stale source exports, missing/mixed assets, or divergent root and `/docs` entry points. Run it before pushing.

Game packs have content-derived filenames so updated game data is requested after deployment. The preceding pack is retained for briefly cached HTML; the legacy `docs/index.pck` also remains for the pre-versioning shell. The runtime is still the official 4.6.3 export template. The engine WASM remains about 36 MiB uncompressed; this update does not claim to shrink the engine.
