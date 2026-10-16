# Scenes context

**Purpose:** Saved native Godot scenes for the world, player, touch controls and countdown.

**Key files:** `main.tscn` is the entry scene; `world.tscn` is generated from `../tools/world_layout.json`; `player.tscn` configures the camera and movement visuals.

**Connections:** The main script reads nodes in these scenes. Keep player camera limits matched to the intended world dimensions (currently 128×88 tiles of 16 px).

**Change & verify:** Regenerate the map with Godot 4.6.3, run web export and review the actual runtime. The compact layout is still experimental; a successful export does not prove every destination is accessible.
