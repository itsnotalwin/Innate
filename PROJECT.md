# INNATE — project state

A Godot 4.6.3 pixel-art exploration game, published for browsers via GitHub Pages.

**Development branch:** `main`.
**Current map source:** `tools/world_layout.json` (experimental 128×88 layout). The saved scene may lag until rebuilt; CI regenerates it on main.
**Title screen:** `tools/web_shell.html` (HTML/CSS/JS) and browser-exported entry points `index.html` / `docs/index.html`.
**Build:** See README and `tools/export_web.py`; deployment workflow in `.github/workflows/deploy-pages.yml`.
**Release:** Configure Settings → Pages → GitHub Actions. A branch creation/commit alone does not change repository default branch or Pages source.
**Quality:** Experimental maps allowed. Valid Godot builds and real screenshots are still evidence requirements.
