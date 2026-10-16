# Workflows context

**Purpose:** Build and deploy the experimental INNATE web game from `main`.

**Key files:** `deploy-pages.yml` downloads Godot 4.6.3 and matching templates, regenerates the map, fails on script-error logs, performs versioned Web export, and publishes the docs artifact.

**Connections:** `../../tools/build_world.gd` and `../../tools/export_web.py` are authoritative. Pages must use the GitHub Actions source, not the old branch-based source.

**Change & verify:** Inspect build and deploy jobs separately. Export success does not imply Pages deployment success.
