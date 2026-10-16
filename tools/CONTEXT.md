# Tools context

**Purpose:** Editable map layout, Godot scene generator, web export, and game launch shell.

**Key files:** `world_layout.json` is the sole current map source. `build_world.gd` writes `../scenes/world.tscn`. `web_shell.html` owns the title screen and runtime boot. `export_web.py` generates and versions the Web files; `check_web_build.py` checks their integrity.

**Connections:** Exported `../index.html` and `../docs/index.html` must remain in sync. The deployment workflow regenerates the map before exporting. Legacy layout copies were removed from the working tree but remain recoverable through Git history.

**Change & verify:** Godot 4.6.3 required. Run scene regeneration, exporter, and web checker. The new 128×88 layout is deliberately experimental; review object positions and player navigation when possible.
