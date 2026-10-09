# INNATE

A peaceful little pixel-art world for Paige. Milestone 01 contains one outdoor map, one animated character, and keyboard/touch walking.

Open `project.godot` in **Godot 4.6.3 Standard** and press **F6 on main.tscn or F5**. Move with **WASD**, **arrow keys**, or the mobile joystick.

See [play/build instructions](docs/README.md), [asset credits and licensing](docs/ASSET_CREDITS.md), and [verified build report](docs/BUILD_REPORT.md).

Sprout Lands — Assets by Cup Nooble. This is a non-commercial project. The selected artwork retains its separate [Basic Pack license](assets/sprout_lands/LICENSE.txt). Do not redistribute it as an asset pack, use it commercially, for NFTs, or for AI training.

## GitHub Pages

The `docs/` directory includes the genuine exported Godot browser game and every runtime file. In **Settings → Pages**, choose **Deploy from a branch**, branch **codex/innate-milestone-01**, folder **/ (root)** or **/docs**, then **Save**. Use the deployment URL GitHub reports after it finishes. The expected project URL is `https://itsnotalwin.github.io/Innate/`.

Pages is enabled on the task branch at **/ (root)**. The root Godot entry page resolves runtime assets from `docs/`. The connected integration cannot change Pages settings (GitHub returns HTTP 403). For a private repository, Pages availability depends on your GitHub plan; keep this repository private unless you explicitly choose otherwise.

To update the published build, run `python tools/export_web.py`, commit the updated root `index.html` and `docs/index*` files, and push the selected Pages branch. The exporter keeps the local `build/web/` and repository `docs/` builds in sync.
