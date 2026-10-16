# Scripts context

**Purpose:** Godot runtime behavior for movement, camera layout, atmosphere, touch controls and countdown.

**Key files:** `main.gd` configures responsive viewport and browser ready signal; `player.gd` owns movement. Related scenes live in `../scenes/`.

**Connections:** The camera and `WORLD_SIZE` in `main.gd` must stay aligned with the authored world dimensions. The browser title screen disappears after `window.innateReady()` is called from the first rendered frame.

**Change & verify:** Use Godot 4.6.3 to load the saved scene and perform browser play checks. Avoid false claims about phone hardware testing.
