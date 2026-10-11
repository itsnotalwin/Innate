#!/usr/bin/env python3
"""Import licensed Sprout Lands artwork used by INNATE from official ZIPs."""
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
GIFT_FILES = {
 'Early Access/Plant update 2/Pine Tree Biome.png': 'pine_biome.png',
 'Early Access/Plant update 2/Trees, stumps and bushes v2.png': 'foliage/trees_stumps_bushes_v2.png',
 'Early Access/Plant update 2/Birch wood Biom.png': 'foliage/birch_biome.png',
 'Early Access/Plant update 2/Cherry Blossom Biom.png': 'foliage/cherry_blossom_biome.png',
 'Early Access/Plant update 2/Birch wood Biom water plants.png': 'foliage/birch_water_plants.png',
 'Early Access/Plant update 2/Cherry Blossom Biom water plants.png': 'foliage/cherry_water_plants.png',
 'Early Access/Plant update 2/Pine Tree Biome water plants.png': 'foliage/pine_water_plants.png',
 'Early Access/Plant update 2/Farming Plants v2.png': 'foliage/farming_plants_v2.png',
 'Early Access/Plant update 2/Farming Plants v2 watered.png': 'foliage/farming_plants_v2_watered.png',
 'Early Access/Plant update 2/wood n shroms.png': 'items/wood_and_mushroom_items.png',
 'read_me.txt': 'FREE_GIFT_LICENSE.txt',
}
if __name__ == '__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('zip');p.add_argument('--gift-pack');args=p.parse_args()
 dest=ROOT/'assets/sprout_lands';dest.mkdir(parents=True,exist_ok=True)
 def import_files(archive, mapping, label):
  with zipfile.ZipFile(archive) as z:
   for source,target in mapping.items():
    matches=[n for n in z.namelist() if n.endswith('/'+source)]
    if len(matches)!=1:raise SystemExit(f'Missing or ambiguous {label} file: {source}')
    output=dest/target;output.parent.mkdir(parents=True,exist_ok=True)
    output.write_bytes(z.read(matches[0]))
 import_files(args.zip,FILES,'Basic Pack')
 if args.gift_pack:import_files(args.gift_pack,GIFT_FILES,'Sorry Pack')
 print('Imported the selected Sprout Lands artwork. Preserve both included licenses and Cup Nooble credit.')
