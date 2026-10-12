#!/usr/bin/env python3
"""Rebuild native atlases; Pillow is only a development dependency."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]
SAMPLES=[('right_side',(15,8)),('bottom_right_corner',(15,15)),('bottom_side',(8,15)),('bottom_left_corner',(0,15)),('left_side',(0,8)),('top_left_corner',(0,0)),('top_side',(8,0)),('top_right_corner',(15,0))]
dirt_config=json.loads((ROOT/'tools/dirt_terrain.json').read_text())
files=['grass','dirt','water','fences','plants','house']
files += [
 'pine_biome',
 'foliage/trees_stumps_bushes_v2',
 'foliage/birch_biome',
 'foliage/cherry_blossom_biome',
 'foliage/birch_water_plants',
 'foliage/cherry_water_plants',
 'foliage/pine_water_plants',
 'foliage/farming_plants_v2',
 'foliage/farming_plants_v2_watered',
 'items/wood_and_mushroom_items',
 'mushroom_variants',
 'wildflowers/btl/flowers',
 'wildflowers/karsiori/flowers',
 'wildflowers/meadow/flowers',
 'innate/environment_trees',
 'innate/mushroom_clusters',
 'innate/flower_clumps',
 'innate/woodland_props',
 'innate/meadow_flowers_detail',
 'innate/meadow_patch_clusters',
]
CUSTOM_ATLASES = {name for name in files if name.startswith('innate/')}
BIG_TILES = {
 'pine_biome': [(112,0,48,48),(80,16,32,32)],
 'foliage/trees_stumps_bushes_v2': [(96,0,48,48),(0,80,32,32),(32,80,32,32),(64,80,32,32),(96,80,32,32)],
 'foliage/birch_biome': [(112,0,48,48),(80,16,32,32),(64,16,16,32)],
 'foliage/cherry_blossom_biome': [(112,0,48,48),(80,16,32,32),(64,16,16,32)],
 'foliage/birch_water_plants': [(16,0,16,32)],
 'foliage/pine_water_plants': [(16,0,16,32)],
}
wildflower_sheet=ROOT/'assets/wildflowers/karsiori/flowers.png'
if wildflower_sheet.exists():
 sheet=Image.open(wildflower_sheet)
 BIG_TILES['wildflowers/karsiori/flowers']=[(x,y,80,80) for y in range(0,sheet.height,80) for x in range(0,sheet.width,80) if sheet.crop((x,y,x+80,y+80)).getbbox()]

def asset_path(name):
 if name.startswith(('wildflowers/','innate/')):return f'assets/{name}.png'
 return f'assets/sprout_lands/{name}.png'

s=f'[gd_resource type="TileSet" load_steps={1 + len(files) * 2} format=3]\n'
for i,name in enumerate(files):s+=f'\n[ext_resource type="Texture2D" path="res://{asset_path(name)}" id="{i}"]\n'
for i,name in enumerate(files):
 im=Image.open(ROOT/asset_path(name)).convert('RGBA')
 atlas_id=name.replace('/','_')
 region_size=64 if name in CUSTOM_ATLASES else 16
 s+=f'\n[sub_resource type="TileSetAtlasSource" id="Atlas_{atlas_id}"]\ntexture = ExtResource("{i}")\ntexture_region_size = Vector2i({region_size}, {region_size})\n'
 occupied=set()
 if name in CUSTOM_ATLASES:
  for y in range(im.height//64):
   for x in range(im.width//64):s+=f'{x}:{y}/0 = 0\n'
  continue
 for rx,ry,rw,rh in BIG_TILES.get(name, []):
  tx,ty=rx//16,ry//16
  cw,ch=rw//16,rh//16
  s+=f'{tx}:{ty}/0 = 0\n{tx}:{ty}/size_in_atlas = Vector2i({cw}, {ch})\n'
  occupied.update((x,y) for y in range(ty,ty+ch) for x in range(tx,tx+cw))
 for y in range(im.height//16):
  for x in range(im.width//16):
   if (x,y) in occupied:continue
   t=im.crop((x*16,y*16,x*16+16,y*16+16));alpha=t.getchannel('A')
   if not alpha.getbbox():continue
   prefix=f'{x}:{y}/0';s+=f'{prefix} = 0\n'
   if name=='wildflowers/meadow/flowers':
    for alternative,(ox,oy) in enumerate([(-4,-3),(3,4),(-2,3),(4,-2),(1,-4),(-3,0),(0,3),(3,0)],1):
     variant=f'{x}:{y}/{alternative}'
     s+=f'{variant} = {alternative}\n{variant}/texture_origin = Vector2i({ox}, {oy})\n'
     if alternative%2:s+=f'{variant}/flip_h = true\n'
   if name=='grass' and y<5 and (x,y) not in [(2,4),(3,4)]:
    s+=f'{prefix}/terrain_set = 0\n{prefix}/terrain = 0\n'
    for bit,point in SAMPLES:
     if t.getpixel(point)[3]>0:s+=f'{prefix}/terrains_peering_bit/{bit} = 0\n'
   if name=='dirt':
    for key,value in dirt_config.get(f'{x},{y}',{}).items():s+=f'{prefix}/{key} = {value}\n'
   if name=='water':
    s+=f'{prefix}/physics_layer_0/polygon_0/points = PackedVector2Array(-8,-8,8,-8,8,8,-8,8)\n'
s+='\n[resource]\ntile_size = Vector2i(16, 16)\nphysics_layer_0/collision_layer = 1\nterrain_set_0/mode = 0\nterrain_set_0/terrain_0/name = "Grass"\nterrain_set_0/terrain_0/color = Color(0.67,0.75,0.4,1)\nterrain_set_0/terrain_1/name = "Dirt"\nterrain_set_0/terrain_1/color = Color(0.9,0.75,0.52,1)\n'
for i,name in enumerate(files):s+=f'sources/{i} = SubResource("Atlas_{name.replace("/", "_")}")\n'
(ROOT/'resources/tilesets/sprout_lands.tres').write_text(s)
