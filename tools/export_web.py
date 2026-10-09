#!/usr/bin/env python3
"""Export with Godot 4.6.3, then publish a validated, cache-safe Pages build."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from check_web_build import source_hashes

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build/web'
PAGES = ROOT / 'docs'
VERSION = '4.6.3'
RUNTIME = ('index.js', 'index.wasm', 'index.audio.worklet.js', 'index.audio.position.worklet.js')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=shutil.which('godot') or shutil.which('godot4'))
    args = parser.parse_args()
    if not args.godot:
        parser.error('Pass --godot with the Godot 4.6.3 Standard executable path.')
    env = os.environ.copy()
    cloud = Path('/workspace/.godot')
    if (cloud / 'data/godot/export_templates/4.6.3.stable').is_dir():
        for key, folder in [('XDG_DATA_HOME', 'data'), ('XDG_CONFIG_HOME', 'config'), ('XDG_CACHE_HOME', 'cache')]:
            env.setdefault(key, str(cloud / folder))
    version = subprocess.check_output([args.godot, '--version'], env=env, text=True).strip()
    if not version.startswith(VERSION + '.'):
        raise SystemExit(f'Use Godot {VERSION} and matching templates; found {version}.')
    BUILD.mkdir(parents=True, exist_ok=True)
    for command in [('--editor', '--import', '--quit'), ('--export-release', 'Web', 'build/web/index.html')]:
        result = subprocess.run([args.godot, '--headless', '--path', str(ROOT), *command],
                                env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        print(result.stdout)
        # Godot can log script errors while returning exit status zero.
        if result.returncode or 'ERROR:' in result.stdout:
            raise SystemExit('Godot reported an error; the tracked Pages build was not replaced.')
    for name in (*RUNTIME, 'index.pck', 'index.html'):
        if not (BUILD / name).is_file() or (BUILD / name).stat().st_size == 0:
            raise SystemExit(f'Incomplete export: {name}. Pages files were not replaced.')
    pack_name = f'game-{digest(BUILD / "index.pck")[:16]}.pck'
    shutil.copy2(BUILD / 'index.pck', BUILD / pack_name)
    shutil.copy2(ROOT / 'assets/sprout_lands/character.png', BUILD / 'loader-character.png')
    html = (BUILD / 'index.html').read_text()
    match = re.search(r'const config = (\{.*\});', html)
    if not match:
        raise SystemExit('Godot configuration missing from export shell.')
    config = json.loads(match[1])
    config['mainPack'] = pack_name
    config['fileSizes'][pack_name] = config['fileSizes'].pop('index.pck')
    html = html[:match.start(1)] + json.dumps(config, separators=(',', ':')) + html[match.end(1):]
    html = '\n'.join(line.rstrip() for line in html.splitlines()).rstrip() + '\n'
    if '$GODOT_' in html:
        raise SystemExit('Unresolved Godot HTML placeholders.')
    (BUILD / 'index.html').write_text(html)
    previous = {}
    manifest_path = PAGES / 'build-manifest.json'
    if manifest_path.exists():
        previous = json.loads(manifest_path.read_text())
    files = (*RUNTIME, pack_name, 'loader-character.png', 'index.html')
    for name in files:
        shutil.copy2(BUILD / name, PAGES / name)
    # Retain the previous pack so a briefly cached HTML page still starts correctly.
    for old in PAGES.glob('game-*.pck'):
        if old.name not in (pack_name, previous.get('main_pack')):
            old.unlink()
    (PAGES / '.nojekyll').touch()
    (ROOT / '.nojekyll').touch()
    (ROOT / 'index.html').write_text(html.replace('<head>', '<head>\n<base href="./docs/">', 1))
    manifest = {'godot': version, 'main_pack': pack_name, 'sources': source_hashes(),
                'files': {name: {'sha256': digest(PAGES / name), 'bytes': (PAGES / name).stat().st_size} for name in files},
                'root_html_sha256': digest(ROOT / 'index.html')}
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    subprocess.run([os.sys.executable, str(ROOT / 'tools/check_web_build.py')], check=True)
    print('Verified Pages build: root and /docs entry points; versioned game data.')


if __name__ == '__main__':
    main()
