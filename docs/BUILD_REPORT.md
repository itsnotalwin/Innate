# INNATE — Milestone 01 build report

**Current mobile update:** see [PORTRAIT_UPDATE.md](PORTRAIT_UPDATE.md) for portrait layout, loading/presentation changes, camera fixes, current tests, and measured performance. Earlier landscape details below describe the initial milestone.

**GitHub Pages is live:** https://itsnotalwin.github.io/Innate/. The public game was verified in Chromium: actual Godot rendering, keyboard movement, no console errors, and no failed resource responses.

**Status: Complete for the requested exploration prototype.** Built and verified on 9 October 2026 (Africa/Johannesburg). Phone hardware, Safari, Firefox, Windows execution, and device FPS remain unverified. No Milestone 02 features were implemented.

## Engine and environment

- Repository/project root: `/workspace/Innate`; empty repository at task start, no existing user files to overwrite.
- Task branch: `codex/innate-milestone-01`.
- Executable: `/usr/local/bin/godot`, matching configured binary `/workspace/.tools/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64`.
- Exact verified version: `4.6.3.stable.official.7d41c59c4`.
- Matching templates: `/workspace/.godot/data/godot/export_templates/4.6.3.stable/`; used `web_nothreads_release.zip`.
- Standard engine, GDScript, Compatibility renderer. Godot, templates, Chromium, Python, Playwright, and Pillow were already installed; none were reinstalled.
- Runtime/network configuration inspected through the cloud-environment runtime skill. Networked commands used the supported permission mechanism and inherited proxy; no restrictions or authentication were bypassed.
- Connected `itsnotalwin/Innate` repository verified private with GitHub API. Remote contained no commit/branch refs, so there was no base branch for a pull request. Delivery includes a reviewable local task-branch commit and ZIP. No default-branch merge, public deployment, or public release.

## World

64×48 tiles at the native **16×16** scale: **1024×768** world pixels. Viewport: **384×216**, default desktop window **1152×648** (3× nearest scaling).

One original curated layout connects a grassy starting clearing, winding dirt loop, wooded mushroom clearing, pond overlook, decorative garden, and cottage. Trees form staggered perimeter belts and deliberate internal clusters. Small flowers, shrubs, mushrooms, grass texture, rocks, stumps, and fallen logs provide landmarks and variation. The world contains 289 Y-sorted nodes including exactly one player. Soil and plants are scenery only.

The saved `scenes/world.tscn` contains editable native TileMapLayer nodes and positioned native objects; the game does not generate the world at runtime. TileSet terrains remain paintable in the editor. Optional construction sources are in `tools/`.

Official free Basic Pack artwork was downloaded successfully through itch.io. Eight original sheets are integrated; the included updated license explicitly allows distributing games and open-source projects with credits and licensing terms. The full license is preserved. No premium assets or other art styles are used. See `ASSET_CREDITS.md` and `ASSET_SHA256.json`.

Maaack integration inspection covered its documentation, base atlas/terrain resource, examples, MIT code notice, and separate art restrictions. Its old grass atlas differs from the current download. INNATE uses new grass atlas configuration and compatible adapted dirt peering rules; no plugin or example map is installed. Inspected upstream revision: `47ddc077797d504b77ca96d602428e2ba3ba21f5`.

## Player, collisions, camera, and controls

- One CharacterBody2D, exported walking speed **72 world px/s**, normalized diagonals, `move_and_slide()`, floating movement mode.
- Native AnimatedSprite2D, actual **48×48** sheet frames with transparent margins; rows down/up/right/left. Walking uses the two available walk frames at 7 fps; idle holds the first idle frame and last facing direction. Animation only switches when its name changes.
- Circle collider of radius 4 near the feet. Trees have 7×7 trunk footprints, while their canopies overlap the player by Y sorting. Large rocks, stumps, logs, cottage, garden fences, water, and perimeter boundaries are solid. Small plants and flowers are walkable.
- Camera2D follows with smoothing, map limits, nearest filtering, and pixel transform snapping. Camera limits were verified at the center and all four edges.
- Native Godot Input Map supports physical WASD and arrow keys. Browser shell prevents focused gameplay keys from scrolling.
- Native Control joystick tracks one finger, supports diagonals, shares the player controller, and releases outside its bounds, on cancellation, loss of focus, and resizing. Hidden on non-touch desktop.
- Fixed widescreen presentation avoids aspect distortion. Portrait has letterboxing and a native rotation label. Web resize events are bridged only for clearing touch and updating that label; all gameplay remains Godot-native.

## Web export

**Generated and launched successfully:** `build/web/index.html`, `index.js`, `index.wasm`, `index.pck`, `index.png`, `index.audio.worklet.js`, and `index.audio.position.worklet.js`.

Genuine Godot 4.6.3 single-threaded Emscripten/WebGL 2 export. No replacement JavaScript game engine, placeholder HTML, GDExtension, thread dependency, or public deployment. Export artifacts are excluded from Git and Godot import; the delivery ZIP includes all generated files.

Served with Python HTTP on `127.0.0.1:8000`, tested with headless Chromium and software WebGL. The compressed delivery is not a promise of game startup size or bandwidth performance; the uncompressed WASM runtime is approximately 36 MiB.

## Verification and repair

Final native editor import and Web export completed with **no script/resource errors**. The saved main scene also loads headlessly. Early sandboxed editor attempts produced editor TCP-listener errors; the final checks used the supported local-network permission and those errors did not recur. Temporary failures were corrected before delivery.

**32/32 native integration checks passed** in `tests/verify_game.gd`. Checks exercise the actual saved scene and physics: player initialization; map cells/Y sorting; 72px/s cardinal speed; equal diagonal speed; four directional walk/idle behaviors; tree, water, cottage, and fence blocking; all world bounds; five camera positions; native touch walking; unrelated-finger release; release outside joystick; cancellation; focus loss; resize clearing.

**12/12 Chromium browser checks passed** in `tests/verify_browser.py`: initialization/rendered canvas; focus; arrow keys; WASD/camera movement; diagonal keys; stable keyboard idle; no scrolling; emulated diagonal touch drag; touch release; touch cancellation; resize during held touch; no console errors/uncaught exceptions.

`tests/evidence/native-results.json`, `native-test.log`, and `browser-results.json` contain final results. `import.log` and `export.log` contain final engine checks. Browser screenshot readbacks produced software-WebGL GPU-stall warnings; no critical runtime errors, browser console errors, missing-resource errors, or uncaught exceptions remain.

Visual review of actual browser screenshots found and corrected dirt transitions, cottage roof alignment, and a cropped fallen-log region. Spawn framing was adjusted into a grassy clearing. The mobile portrait review identified a missing rotation hint; Web resize/orientation handling was fixed and both suites retested successfully. The final tree screenshot visibly shows the character partly obscured by the canopy; pond shoreline and cottage composition were inspected from actual rendering.

## Actual-game screenshot evidence

- `tests/evidence/desktop-spawn.png`: clearing, player, cottage, and path, 1152×648.
- `tests/evidence/desktop-tree.png`: character behind a tree canopy, 1152×648.
- `tests/evidence/desktop-pond.png`: pond shore and connecting paths, 1152×648.
- `tests/evidence/desktop-diagonal.png`: nearby location after diagonal movement.
- `tests/evidence/mobile-landscape.png`: 844×390 touch-emulated landscape.
- `tests/evidence/mobile-after-touch.png`: scene after joystick walking.
- `tests/evidence/mobile-portrait.png`: 390×844 letterboxed portrait with rotation hint.

All screenshots are captured from the running genuine Web export. No promotional screenshots are presented as implementation evidence.

## Known limits and next step

No actual phone, iOS Safari, Firefox, or local Windows editor was tested. Browser touch is emulated. Pixel art is nearest-filtered; fractional mobile scale may produce uneven pixel widths, while the default 3× desktop scale is exact. Portrait is intentionally letterboxed and recommends landscape. Device FPS and a 60fps performance target were not measured or claimed. Water is static. The cottage has no interior. There are no save systems or additional maps.

Before defining Milestone 02, play this build on the intended phone and Windows installation and review walking speed, camera framing, and world composition with Paige. No additional systems have been implemented.

## GitHub Pages delivery correction

The original delivery excluded generated Web artifacts from Git. At the user's request, the complete tested Web export is now also tracked in `docs/`, the folder GitHub Pages supports for branch deployments. `.nojekyll` is included and `docs/.gdignore` prevents re-import. The export helper keeps `docs/` synchronized with `build/web/`.

The task branch is prepared for pushing to the connected repository. The connected integration returns HTTP 403 (`Resource not accessible by integration`) for the Pages API, so automatic activation is blocked by its GitHub permissions. Enable **Deploy from a branch → codex/innate-milestone-01 → /docs** in GitHub Settings. No Pages deployment success is claimed until enabled and verified. The user's latest instruction authorizes Pages publishing and supersedes the original no-public-deployment restriction; repository visibility remains private.

### Root-folder Pages support

Pages was enabled successfully by the user on `codex/innate-milestone-01` with source `/`. The integration can read that configuration but receives HTTP 403 when updating it. A root `index.html` now uses the genuine Godot shell with a relative `docs/` base URL, allowing the existing root-folder configuration to serve the game. Root `.nojekyll` disables Jekyll processing, and the export helper maintains both supported entry locations.

The repository is now public, as verified after the user enabled Pages. This does not change the Basic Pack terms: the included license explicitly permits open-source game projects, and the source retains the required credits and complete artwork license.

The root entry was verified at `http://127.0.0.1:8002/Innate/`: all 12 browser checks passed, including emulated mobile touch, cancellation, resize, and no console errors.

### Public deployment verification

GitHub Pages run `37908992745` completed successfully for commit `7aecf54`, serving branch `codex/innate-milestone-01` from `/`. Native Chromium loaded the public HTTPS URL through the configured cloud proxy, trusting the already-installed cloud CA public keys. The game rendered, keyboard movement changed the scene, and all resources (including audio worklets) loaded with no browser console errors or failed HTTP responses. Results and an actual live-game screenshot are saved in `tests/evidence/live-pages-results.json` and `live-pages.png`. Previous local desktop/mobile tests remain 12/12 passing.
