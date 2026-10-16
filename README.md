# INNATE

**[Play INNATE in your browser](https://itsnotalwin.github.io/Innate/)**

A peaceful little pixel-art world for Paige. Milestone 01 contains one outdoor map, one animated character, and keyboard/touch walking.

Open `project.godot` in **Godot 4.6.3 Standard** and press **F6 on main.tscn or F5**. The experimental 128×88-tile layout is designed for portrait phones, with separated destinations connected by a central road loop. Move with **WASD**, **arrow keys**, or touch and drag anywhere on the screen. Pinch with two fingers to zoom from 0.25× to 1.8×; the default view remains 1×. A compact top-right countdown shows the time until local midnight on May 26, 2027.

See the [portrait update and measured limits](docs/PORTRAIT_UPDATE.md), [play/build instructions](docs/README.md), [asset credits and licensing](docs/ASSET_CREDITS.md), and [verified build report](docs/BUILD_REPORT.md).

Sprout Lands — Assets by Cup Nooble. This is a non-commercial project. The selected artwork retains its separate [Basic Pack license](assets/sprout_lands/LICENSE.txt). Do not redistribute it as an asset pack, use it commercially, for NFTs, or for AI training.

## Development and deployment

The one development branch is **main**. It includes the experimental compact layout, which is allowed to ship without a gameplay sign-off. The active editable layout is `tools/world_layout.json`; historical layouts remain in Git history rather than separate working copies. GitHub Actions regenerates `scenes/world.tscn` from the layout and runs the Godot Web export on each push to main. Development builds are exploratory; art placement and path accessibility are not guaranteed until played.

The INNATE title screen lives in `tools/web_shell.html` and is exported into the root `index.html` and `docs/index.html`. The browser shows the title and PLAY button before starting Godot. Do not edit generated shells alone: a fresh export will overwrite them.

**One-time Pages setting:** open **Settings → Pages → Build and deployment**, select **GitHub Actions** as the source. The workflow `Deploy INNATE` publishes the updated game from main. If GitHub Pages remains in its old branch-publishing mode, main commits will not automatically become the live site.

To build locally with Godot 4.6.3 Standard and the matching Web export templates:
```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tools/build_world.gd
python tools/export_web.py
python tools/check_web_build.py
```

The title no longer displays asset attribution. Original asset credits and licenses remain in the repo because the current game still references Sprout Lands artwork (including the player sprite).