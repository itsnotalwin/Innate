# Docs context

**Purpose:** Godot browser deployment output plus play/build documentation and retained license references.

**Important files:** `index.html` is generated from `../tools/web_shell.html` by `../tools/export_web.py`. Runtime scripts/WASM/pack files and `build-manifest.json` form one coherent export. Readmes and license documentation are authored content.

**Connections:** CI publishes this directory through GitHub Actions. Root `../index.html` targets the same runtime using `<base href="./docs/">`; when publishing this folder as its own artifact, docs/index.html is the entry point.

**Change & verify:** Do not hand-edit generated binaries. After a source edit regenerate the export and run `python tools/check_web_build.py`. Old export manifests are stale until regeneration.
