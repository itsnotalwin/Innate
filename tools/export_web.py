#!/usr/bin/env python3
"""Import and export with the installed Godot Standard engine and matching templates."""
import argparse, os, pathlib, shutil, subprocess
ROOT=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--godot',default=shutil.which('godot') or shutil.which('godot4'))
a=p.parse_args()
if not a.godot:raise SystemExit('Pass --godot with the path to your Godot 4.6.3 executable.')
env=os.environ.copy()
# Use the already-configured cloud templates without changing the user's home.
cloud=pathlib.Path('/workspace/.godot')
if (cloud/'data/godot/export_templates/4.6.3.stable').is_dir():
 for key,folder in [('XDG_DATA_HOME','data'),('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache')]:env.setdefault(key,str(cloud/folder))
(ROOT/'build/web').mkdir(parents=True,exist_ok=True)
for command in [['--version'],['--headless','--editor','--import','--quit'],['--headless','--export-release','Web','build/web/index.html']]:
 subprocess.run([a.godot,'--path',str(ROOT),*command],cwd=ROOT,env=env,check=True)
for file in (ROOT/'build/web').iterdir():
 if file.is_file() and file.name != '.gdignore':shutil.copy2(file,ROOT/'docs'/file.name)
(ROOT/'docs/.nojekyll').touch()
print('Web build ready in build/web and docs/. GitHub Pages: deploy task branch /docs.')
