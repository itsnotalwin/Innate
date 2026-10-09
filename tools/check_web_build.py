#!/usr/bin/env python3
"""Check tracked Pages files match one complete export before committing/deploying."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAGES = ROOT / 'docs'


def source_hashes():
    files = [ROOT / 'project.godot', ROOT / 'export_presets.cfg', ROOT / 'tools/web_shell.html']
    for directory in ('scenes', 'scripts', 'resources', 'assets'):
        files.extend(path for path in (ROOT / directory).rglob('*') if path.is_file())
    return {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(files)}


def main():
    manifest = json.loads((PAGES / 'build-manifest.json').read_text())
    if manifest.get('sources') != source_hashes():
        raise SystemExit('Game sources changed since export. Run python tools/export_web.py before deploying.')
    for name, expected in manifest['files'].items():
        data = (PAGES / name).read_bytes()
        if len(data) != expected['bytes'] or hashlib.sha256(data).hexdigest() != expected['sha256']:
            raise SystemExit(f'Pages file does not match export: {name}')
    root_html = (ROOT / 'index.html').read_text()
    if hashlib.sha256((ROOT / 'index.html').read_bytes()).hexdigest() != manifest['root_html_sha256']:
        raise SystemExit('Root HTML does not match export.')
    docs_html = (PAGES / 'index.html').read_text()
    if root_html.replace('<base href="./docs/">\n', '', 1) != docs_html:
        raise SystemExit('Root and /docs entry points differ beyond their base URL.')
    config = json.loads(re.search(r'const config = (\{.*\});', docs_html)[1])
    if config['mainPack'] != manifest['main_pack']:
        raise SystemExit('HTML refers to a different game pack.')
    for name, size in config['fileSizes'].items():
        if (PAGES / name).stat().st_size != size:
            raise SystemExit(f'Wrong download size for {name}')
    if not (ROOT / '.nojekyll').exists() or not (PAGES / '.gdignore').exists():
        raise SystemExit('Missing Pages or Godot import guards.')
    print(f'PASS: {len(manifest["files"])} Pages files, hashes, sizes, source freshness, game pack, and both entry points.')


if __name__ == '__main__':
    main()
