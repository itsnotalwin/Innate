# Mobile and movement foundation audit

No interaction systems or new map scenery were added in this pass.

## Changes

- Touch movement now ramps up smoothly after its small deadzone; motion is capped at normal walking speed. The first finger keeps control until release, cancellation, resize, pause or loss of focus.
- Losing browser focus, hiding/changing tabs, navigating away and returning, or pausing the app clears keyboard and touch input. Resize also clears held keyboard input, and the camera resets interpolation after lifecycle changes.
- Safe-area measurements now include all four phone edges. Canvas dimensions are only reassigned when their actual render size changes, avoiding needless graphics resets during repeated resize events.
- Missing game files show a retry screen during startup. A graphics context loss after launch replaces the game screen with the same retry action. A 30-second startup watchdog handles stalled loads.
- Existing tree, house, fence and shoreline collision shapes and camera zoom are unchanged.

## Evidence

- Native game checks: 52/52 passed, including player speed, diagonal movement, collision, sliding away from obstacles, touch ownership, analog movement, app pause, resize, camera bounds and unchanged zoom.
- Browser checks: 28/28 passed, including keyboard and touch movement, release/cancel, simulated blur/tab lifecycle, repeated portrait/landscape rotation, safe-area bridge, runtime/pack download failure and retry, graphics recovery, and no unexpected console errors.
- Physics map audit: all 12,708 open 16-pixel cells are connected. The player completed 494 swept steps on routes to and from all six destinations. No destination is blocked; no isolated walkable path cells exist. The 26 blocked painted path cells overlap the intentional cottage/garden footprint or its fences.
- Route painting audit: 1,176 path cells connected, no water crossings and no unintended solid props on paths.
- Paired software-WebGL sample against commit `674c9cd`: portrait mean 71.4 ms baseline / 81.9 ms update (p95 83.4 / 100 ms); desktop mean 75.2 / 72.1 ms (p95 100 / 100 ms). Variation is too high to call a regression or a performance improvement. This is a software-rendered browser, not a phone benchmark.

Real-device testing remains necessary, especially background/resume behavior and sustained frame pacing on the target phone/browser.
