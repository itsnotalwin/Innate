#!/usr/bin/env python3
"""Rebuild native atlases; Pillow is only a development dependency."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]
SAMPLES=[('right_side',(15,8)),('bottom_right_corner',(15,15)),('bottom_side',(8,15)),('bottom_left_corner',(0,15)),('left_side',(0,8)),('top_left_corner',(0,0)),('top_side',(8,0)),('top_right_corner',(15,0))]
dirt_config=json.loads((ROOT/'tools/dirt_terrain.json').read_text())
files=['grass','dirt','water','fences','plants','house']
s='[gd_resource type="TileSet" load_steps=13 format=3]\n'
for i,name in enumerate(files):s+=f'\n[ext_resource type="Texture2D" path="res://assets/sprout_lands/{name}.png" id="{i}"]\n'
for i,name in enumerate(files):
 im=Image.open(ROOT/f'assets/sprout_lands/{name}.png').convert('RGBA')
 s+=f'\n[sub_resource type="TileSetAtlasSource" id="Atlas_{name}"]\ntexture = ExtResource("{i}")\ntexture_region_size = Vector2i(16, 16)\n'
 for y in range(im.height//16):
  for x in range(im.width//16):
   t=im.crop((x*16,y*16,x*16+16,y*16+16));alpha=t.getchannel('A')
   if not alpha.getbbox():continue
   prefix=f'{x}:{y}/0';s+=f'{prefix} = 0\n'
   if name=='grass' and y<5 and (x,y) not in [(2,4),(3,4)]:
    s+=f'{prefix}/terrain_set = 0\n{prefix}/terrain = 0\n'
    for bit,point in SAMPLES:
     if t.getpixel(point)[3]>0:s+=f'{prefix}/terrains_peering_bit/{bit} = 0\n'
   if name=='dirt':
    for key,value in dirt_config.get(f'{x},{y}',{}).items():s+=f'{prefix}/{key} = {value}\n'
   if name=='water':
    s+=f'{prefix}/physics_layer_0/polygon_0/points = PackedVector2Array(-8,-8,8,-8,8,8,-8,8)\n'
s+='\n[resource]\ntile_size = Vector2i(16, 16)\nphysics_layer_0/collision_layer = 1\nterrain_set_0/mode = 0\nterrain_set_0/terrain_0/name = "Grass"\nterrain_set_0/terrain_0/color = Color(0.67,0.75,0.4,1)\nterrain_set_0/terrain_1/name = "Dirt"\nterrain_set_0/terrain_1/color = Color(0.9,0.75,0.52,1)\n'
for i,name in enumerate(files):s+=f'sources/{i} = SubResource("Atlas_{name}")\n'
(ROOT/'resources/tilesets/sprout_lands.tres').write_text(s)
