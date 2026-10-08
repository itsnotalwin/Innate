#!/usr/bin/env python3
"""Import only used, licensed Basic Pack sheets from an official downloaded ZIP."""
import argparse, pathlib, zipfile
ROOT = pathlib.Path(__file__).resolve().parents[1]
FILES = {
 'Tilesets/Grass.png': 'grass.png',
 'Tilesets/Water.png': 'water.png',
 'Tilesets/Tilled Dirt.png': 'dirt.png',
 'Tilesets/Fences.png': 'fences.png',
 'Tilesets/Wooden House.png': 'house.png',
 'Objects/Basic Grass Biom things 1.png': 'nature.png',
 'Objects/Basic Plants.png': 'plants.png',
 'Characters/Basic Charakter Spritesheet.png': 'character.png',
 'read_me.txt': 'LICENSE.txt',
}
if __name__ == '__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('zip');args=p.parse_args()
 dest=ROOT/'assets/sprout_lands';dest.mkdir(parents=True,exist_ok=True)
 with zipfile.ZipFile(args.zip) as z:
  for source,target in FILES.items():
   matches=[n for n in z.namelist() if n.endswith('/'+source)]
   if len(matches)!=1:raise SystemExit(f'Missing or ambiguous Basic Pack file: {source}')
   (dest/target).write_bytes(z.read(matches[0]))
 print('Imported',len(FILES),'files. Preserve LICENSE.txt and Cup Nooble credits.')
