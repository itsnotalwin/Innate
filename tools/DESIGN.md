# INNATE web title screen

**Design:** A deliberately minimal opening with only the game name **INNATE**, a prominent **PLAY** button, a quiet loading indicator, and a recoverable error state. No asset-pack attribution appears on-screen. Deep forest and teal gradients, a soft moon, silhouetted hills, fine gold line work and drifting fireflies evoke a calm exploratory world without referencing old sprites. Cream serif display lettering, high-contrast rounded CTA, clear keyboard focus, small-screen layout and reduced-motion support are intentional.

**Implementation:** Source is `web_shell.html`; export creates `../docs/index.html` and root `../index.html`. PLAY starts the Godot engine; the screen fades only after the first actual frame calls `window.innateReady()`.

**Evidence:** A genuine updated `SCREENSHOT.png` is still required. This environment does not have Godot installed or permission to run the live deployment; do not treat this document as visual verification. Capture the running page at 1440×900 desktop and 390×844 mobile after a successful deployment.
