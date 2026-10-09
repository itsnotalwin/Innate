# Portrait mobile update

INNATE now fills a portrait phone screen, has a custom loading screen, and keeps gameplay free of text overlays. The existing map, walking speed, and collision footprints are unchanged.

## Changes

- Default logical view: 216×384 portrait, expanded to fit the available aspect ratio. Desktop/landscape uses a 384×216 basis. Extremely wide layouts stay within map bounds.
- Gameplay contains only the native touch joystick on touch devices. Title, dedication, credit overlay, and rotation message were removed. Required Cup Nooble attribution is on the custom loading screen and in the documentation.
- The Godot logo splash is disabled. The INNATE loader uses the existing character art, a real download progress bar, and a retry action for a failed load. It clears after the first rendered game frame.
- Camera follow runs on physics ticks with physics interpolation enabled. Whole-game-pixel snapping is disabled, and canvas-items rendering retains nearest filtering for the original artwork. Native tests verify small camera steps and fractional camera positions.
- A 720px maximum render edge limits GPU fill work independently of screen pixel density. CSS still fills the screen. The effective render size is 333×720 on a 390×844 phone, so there are no portrait letterbox bars. Safe-area padding protects the joystick from phone home indicators.
- Resize/focus handling releases touch input. Resize work is coalesced, and layout sizing is bounded to the map.

## Verification

Final checks: **37/37 native integration checks** and **18/18 browser checks**. These cover the existing movement, animation, obstacle and boundary behavior plus portrait layout, ultrawide bounds, camera steps, touch cancellation, held-touch resizing, high-density render limits, custom loading, and download-error retry behavior.

Screenshots in `tests/evidence/` are captured from the actual updated game. `mobile-portrait.png` shows the full portrait layout; `loading-screen.png` shows the replacement loader. No physical phone, Safari, or Windows execution has been tested in this cloud environment.

## Performance evidence

`tests/profile_web.py --baseline-ref 455b9f5` compares the previous deployed export with the update using fresh Chromium processes, local HTTP, and software WebGL. Each result is one four-second movement sample; these are diagnostic measurements, not real-phone FPS claims.

| Case | Previous build | Portrait update |
| --- | --- | --- |
| 390×844, device pixel ratio 3: render buffer | 1170×2532 | 333×720 |
| Same case: mean frame interval | 74.21 ms | 30.43 ms |
| Same case: 95th percentile frame interval | 100.0 ms | 50.1 ms |
| Same case: local time to game ready | 1595 ms | 1371 ms |
| 1152×648 desktop: render buffer | 1152×648 | 720×405 |
| Same desktop case: mean frame interval | 38.09 ms | 38.30 ms |

The high-density test uses approximately 92% fewer render-buffer pixels and shows substantially lower frame cost in this environment. Desktop frame time was effectively unchanged. Initial single-density portrait samples were 30.88 ms before and 34.19 ms after; filling the entire portrait screen draws more of the world than the former letterboxed view. All raw samples are retained. A stable 60fps target has **not** been demonstrated, and actual phone performance remains to be checked.

The official Godot WASM runtime remains approximately 36 MiB uncompressed. This update does not claim to reduce its download size. No custom engine or extra runtime dependencies were introduced.

## Deployment integrity

`python tools/export_web.py` imports and exports with Godot 4.6.3, rejects engine/script errors, versions the game pack by content hash, generates both supported Pages entry points, and records source/file fingerprints in `docs/build-manifest.json`.

`python tools/check_web_build.py` checks source freshness, runtime hashes/sizes, the active pack, and root-versus-`/docs` entry consistency. A real unexported HTML-shell edit was correctly rejected, then passed after re-export. Run the checker before every push. The previous versioned pack and the pre-versioning `index.pck` remain available for temporarily cached HTML.

The repository's existing GitHub Pages root-folder configuration is retained. The currently active game pack is named in the manifest. The initial landscape implementation and earlier reports are historical; this document describes the mobile-focused update.

## Next validation

Open the live game on the intended phone and check camera motion, perceived sharpness, joystick comfort, startup time, and switching away/back to the browser. Report the phone model and browser with any remaining issue so profiling can target that device.
