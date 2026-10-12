extends SceneTree
## Offline construction only. Saves editable native nodes and painted tile cells.
var world := Node2D.new()
var tiles: TileSet = load("res://resources/tilesets/sprout_lands.tres")
var nature: Node2D
var ground: TileMapLayer
var paths: TileMapLayer
var details: TileMapLayer
var water: TileMapLayer
var pond := {}
var route := {}
var layout: Dictionary

const TREE_ATLAS := "res://assets/innate/environment_trees.png"
const MUSHROOM_ATLAS := "res://assets/innate/mushroom_clusters.png"
const FLOWER_ATLAS := "res://assets/innate/meadow_patch_clusters.png"
const FLOWER_DETAIL_ATLAS := "res://assets/innate/meadow_flowers_detail.png"
const PROP_ATLAS := "res://assets/innate/woodland_props.png"
const COMBINED_ATLAS := "res://assets/innate/environment_atlas.png"
const ATLAS_OFFSETS := {
	TREE_ATLAS: Vector2(0, 0),
	MUSHROOM_ATLAS: Vector2(256, 0),
	"res://assets/innate/flower_clumps.png": Vector2(0, 256),
	FLOWER_DETAIL_ATLAS: Vector2(256, 256),
	FLOWER_ATLAS: Vector2(0, 512),
	PROP_ATLAS: Vector2(256, 512),
}
const WORLD_X_SCALE := 1.203125 # 154 tiles wide, matching the reference map's 1.5:1 framing.

func _initialize() -> void:
	call_deferred("build")

func sx(x: float) -> float:
	return x * WORLD_X_SCALE

func map_cell(position: Vector2) -> Vector2i:
	# Object positions use tile coordinates and sit at cell centers (+0.5 tiles).
	# Match the occupied cell used by collision and traversal audits.
	return Vector2i(roundi(position.x), roundi(position.y))

func on_painted_path(cell: Vector2i) -> bool:
	return paths.get_cell_source_id(cell) != -1

func route_clearance(cell: Vector2i) -> bool:
	for dy in range(-1,2):
		for dx in range(-1,2):
			if route.has(cell+Vector2i(dx,dy)): return false
	return true

func own(node: Node, parent: Node, node_name: String) -> void:
	node.name = node_name
	parent.add_child(node)
	node.owner = world

func layer(node_name: String, parent: Node = null) -> TileMapLayer:
	if parent == null: parent = world
	var node := TileMapLayer.new()
	node.tile_set = tiles
	own(node, parent, node_name)
	return node

func add_shape(parent: Node, shape: Shape2D, offset: Vector2 = Vector2.ZERO) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	own(body, parent, "Solid")
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = offset
	own(collision, body, "Footprint")

func rectangle(parent: Node, size: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	add_shape(parent, shape, offset)

func curve_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)

func paint_path(points: Array, radius := 1, bridge_diagonals := true) -> void:
	var closed: bool = points.size() > 2 and points[0] == points[points.size()-1]
	for i in range(points.size()-1):
		var start := Vector2(points[i][0],points[i][1])
		var end := Vector2(points[i+1][0],points[i+1][1])
		var previous_control := Vector2(points[i-1][0],points[i-1][1]) if i > 0 else (Vector2(points[points.size()-2][0],points[points.size()-2][1]) if closed else start * 2.0 - end)
		var next_control := Vector2(points[i+2][0],points[i+2][1]) if i+2 < points.size() else (Vector2(points[1][0],points[1][1]) if closed else end * 2.0 - start)
		var steps := maxi(1, int(start.distance_to(end)*4))
		var previous := Vector2i(roundi(start.x),roundi(start.y))
		for step in range(steps+1):
			var p := curve_point(previous_control,start,end,next_control,float(step)/steps)
			var cell := Vector2i(roundi(p.x),roundi(p.y))
			# Add a bridge only when successive samples touch diagonally. The old
			# implementation added a southeast 2x2 block at every sample, which
			# biased and widened every route even when no diagonal gap existed.
			if bridge_diagonals and cell.x != previous.x and cell.y != previous.y:
				route[Vector2i(cell.x,previous.y)] = true
			for dy in range(-radius,radius+1):
				for dx in range(-radius,radius+1):
					route[Vector2i(roundi(p.x)+dx,roundi(p.y)+dy)] = true
			previous = cell

func object_from(node_name: String, cell: Vector2, texture_path: String, region: Rect2, solid_size := Vector2.ZERO) -> Node2D:
	var object := Node2D.new()
	object.position = cell * 16.0 + Vector2(8, 8)
	own(object, nature, node_name)
	var sprite := Sprite2D.new()
	var resolved_path := texture_path if texture_path.begins_with("res://") else "res://assets/sprout_lands/" + texture_path
	if ATLAS_OFFSETS.has(resolved_path):
		region.position += ATLAS_OFFSETS[resolved_path]
		sprite.texture = load(COMBINED_ATLAS)
	else:
		sprite.texture = load(resolved_path)
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.position.y = -region.size.y / 2.0 + 4.0
	own(sprite, object, "Artwork")
	if solid_size != Vector2.ZERO:
		rectangle(object, solid_size)
	return object

func tree(cell: Vector2, kind: int, node_name: String) -> void:
	if not route_clearance(map_cell(cell)): return
	var selector := absi(roundi(cell.x) * 37 + roundi(cell.y) * 71 + kind * 13)
	var variant := posmod(kind, 15)
	if kind in [3, 8, 9, 12]: variant = [3, 8, 9, 12][selector % 4]
	elif kind in [4, 10]: variant = [4, 10, 14][selector % 3]
	elif kind in [5, 6, 7, 11]: variant = [0, 1, 5, 6, 7, 11, 12, 13, 14][selector % 9]
	var region := Rect2((variant % 4) * 64, int(variant / 4) * 64, 64, 64)
	var scale_factor := 0.92 if selector % 5 == 0 else (0.78 if selector % 3 == 0 else 0.86)
	if node_name.begins_with("NorthInnerTree") or node_name.begins_with("SouthInnerTree") or node_name.begins_with("GroveTree"):
		scale_factor = 1.0 if selector % 4 == 0 else 0.90
	var placed := object_from(node_name, cell, TREE_ATLAS, region, Vector2(7, 6))
	placed.get_node("Artwork").scale = Vector2.ONE * scale_factor

func cluster_from(node_name: String, cell: Vector2, atlas: String, variant: int, scale_factor: float, solid_size := Vector2.ZERO) -> Node2D:
	var index := posmod(variant, 16)
	var region := Rect2((index % 4) * 64, int(index / 4) * 64, 64, 64)
	var object := object_from(node_name, cell, atlas, region, solid_size)
	var sprite: Sprite2D = object.get_node("Artwork")
	sprite.scale = Vector2.ONE * scale_factor
	sprite.position.y = (-region.size.y / 2.0 + 4.0) * scale_factor
	return object

func mushroom_cluster(cell: Vector2, variant: int, node_name: String, scale_factor := 0.88) -> void:
	cluster_from(node_name, cell, MUSHROOM_ATLAS, variant, scale_factor)

func flower_clump(cell: Vector2, variant: int, node_name: String, scale_factor := 0.58) -> void:
	cluster_from(node_name, cell, FLOWER_ATLAS, variant, scale_factor)

func flower_detail(cell: Vector2, variant: int, node_name: String, scale_factor := 0.42) -> void:
	cluster_from(node_name, cell, FLOWER_DETAIL_ATLAS, variant, scale_factor)

func woodland_prop(cell: Vector2, variant: int, node_name: String, scale_factor := 0.7, solid_size := Vector2.ZERO) -> Node2D:
	return cluster_from(node_name, cell, PROP_ATLAS, variant, scale_factor, solid_size)

func low_tree(cell: Vector2, variant: int, node_name: String, scale_factor := 0.46) -> Node2D:
	return cluster_from(node_name, cell, TREE_ATLAS, variant, scale_factor)

func add_river(points: Array, radius: int) -> void:
	for i in range(points.size()-1):
		var start := Vector2(points[i][0],points[i][1])
		var end := Vector2(points[i+1][0],points[i+1][1])
		var steps := maxi(1,int(start.distance_to(end)*3.0))
		for step in range(steps+1):
			var point := start.lerp(end,float(step)/steps)
			var center := Vector2i(roundi(point.x),roundi(point.y))
			for dy in range(-radius,radius+1):
				for dx in range(-radius,radius+1):
					if Vector2(dx,dy).length() <= radius+0.35:
						pond[center+Vector2i(dx,dy)] = true

func build_river_reeds() -> void:
	# Reeds follow both banks of the full river to keep the water integrated into the map.
	var placed := {}
	for y in range(5,int(layout.size[1])-5,3):
		var center_x := river_center_x(float(y))
		for side in [-1,1]:
			for offset in [3,5]:
				var cell := Vector2i(center_x+side*offset,y+((y+side+offset)%3)-1)
				if placed.has(cell) or pond.has(cell) or route.has(cell): continue
				placed[cell] = true
				woodland_prop(Vector2(cell),4+posmod(y+side+offset,3),"RiverBankReeds_%d_%d"%[cell.x,cell.y],0.58)

func river_center_x(y: float) -> int:
	var points: Array = layout.river_path
	for i in range(points.size()-1):
		var a := Vector2(points[i][0],points[i][1])
		var b := Vector2(points[i+1][0],points[i+1][1])
		if y < a.y or y > b.y: continue
		return roundi(lerpf(a.x,b.x,inverse_lerp(a.y,b.y,y)))
	return int(layout.river_path.back()[0])

func edge_tree_kind(cell: Vector2i) -> int:
	var selector := absi(cell.x * 17 + cell.y * 31)
	if cell.x <= 3 or cell.x >= int(layout.size[0])-4 or cell.y <= 4 or cell.y >= int(layout.size[1])-8:
		return [3,4,5,12][selector % 4]
	if cell.x >= 82 and cell.y <= 43:
		return [10, 11, 10, 6][selector % 4]
	if cell.x >= 38 and cell.x <= 72 and cell.y <= 23:
		return [8, 9, 6, 3][selector % 4]
	if cell.y >= 54:
		return [3, 4, 5, 12][selector % 4]
	if cell.y <= 22:
		return [3, 6, 7, 1][selector % 4]
	return [0, 1, 2, 3, 4, 6][selector % 6]

func mushroom(cell: Vector2, variant: int, scale_factor: float, tint: int, node_name: String) -> void:
	# Use the same detailed woodland mushroom family everywhere; tint now selects
	# a palette-matched silhouette rather than switching back to the legacy pack.
	var selected := posmod(variant * 5 + tint, 16)
	mushroom_cluster(cell, selected, node_name, scale_factor * 0.62)

func build() -> void:
	layout = JSON.parse_string(FileAccess.get_file_as_string("res://tools/world_layout.json"))
	world.name = "World"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(world)
	water = layer("Water")
	var water_material := ShaderMaterial.new()
	water_material.shader = load("res://shaders/water.gdshader")
	water.material = water_material
	ground = layer("Ground")
	paths = layer("Paths")
	details = layer("GroundDetails")
	for row in layout.pond_rows:
		for x in range(row[1], row[2]+1):
			pond[Vector2i(x,row[0])] = true
	# Extend the existing eastern stream beyond both map edges into one continuous river.
	add_river(layout.river_path, 2)
	# Open a short walkable channel through the water beneath the authored footbridge.
	for bridge_key in ["pond_bridge_bounds","creek_bridge_bounds"]:
		var bridge_bounds: Array = layout[bridge_key]
		for y in range(bridge_bounds[1],bridge_bounds[3]+1):
			for x in range(bridge_bounds[0],bridge_bounds[2]+1): pond.erase(Vector2i(x,y))
	# Water extends under transparent shoreline pixels; only open water has physics.
	for cell in pond:
		water.set_cell(cell, 2, Vector2i((cell.x+cell.y)%4,0))
	var shore_water := layer("ShoreUnderlay")
	world.move_child(shore_water, 0)
	shore_water.collision_enabled = false
	shore_water.material = water_material
	for cell in pond:
		for y in range(-1,2):
			for x in range(-1,2):
				shore_water.set_cell(cell+Vector2i(x,y), 2, Vector2i(0,0))
	var land: Array[Vector2i] = []
	var world_width: int = layout.size[0]
	var world_height: int = layout.size[1]
	for y in range(world_height):
		for x in range(world_width):
			var cell := Vector2i(x,y)
			if not pond.has(cell): land.append(cell)
	ground.set_cells_terrain_connect(land, 0, 0)
	paint_path(layout.path)
	# The cottage yard sits inside a readable walking loop, as in the selected mockup.
	# A slightly wider, bridged stroke reads as one continuous loop at game scale.
	paint_path(layout.cottage_loop,1,true)
	# A wide outer route links the destination approaches into one continuous loop.
	paint_path(layout.outer_loop)
	for branch in layout.path_branches:
		paint_path(branch)
	# A light footpath circles the flower clearing and rejoins the south trail.
	paint_path(layout.meadow_trail,1,true)
	# This quieter inner trail crosses the meadow and ends at its rest stone,
	# giving players a walkable view through the flowers instead of only around them.
	paint_path(layout.meadow_inner_trail,1,true)
	# The cottage garden gate opens onto the northern walking route.
	paint_path(layout.garden_access,1,true)
	var garden: Array = layout.garden
	var garden_gate_x := roundi((float(garden[0])+float(garden[2]))/2.0)
	# Keep the garden green, with a single clear path between both gates.
	paint_path([[garden_gate_x,garden[1]-2],[garden_gate_x,garden[3]+2]],1)
	# Carry that gate path through the hub to the shared outer loop.
	paint_path([[68.0,55.0],[69.0,57.0],[70.0,59.0],[72.0,60.0]],1,true)
	# A footpath follows the west bank into the creekside rest clearing.
	paint_path(layout.creek_trail,1)
	paint_path(layout.creek_rest_trail,1,true)
	paint_path(layout.creek_bridge_trail,1,true)
	# A slim loop makes the pond garden a destination from the main road.
	paint_path(layout.pond_garden_trail,1,true)
	paint_path(layout.pond_bridge_trail,1,true)
	# A soft loop turns the northern fruit grove into a walkable destination.
	paint_path(layout.orchard_trail,1,true)
	# A small loop lets the mushroom glade unfold beyond its entrance spur.
	paint_path(layout.mushroom_trail,1,true)
	# The main loop frames the central green; avoid stacking a second hub ring.
	# An apron joins the cottage door to the main path.
	var cottage: Array = layout.cottage
	for y in range(cottage[1]+2,cottage[1]+8):
		for x in range(cottage[0]-1,cottage[0]+2): route[Vector2i(x,y)] = true
	var path_cells: Array[Vector2i] = []
	for cell in route:
		if not pond.has(cell): path_cells.append(cell)
	paths.set_cells_terrain_connect(path_cells, 0, 1)
	# Ground variation follows fixed meadow patches rather than random objects.
	for y in range(2,world_height-2):
		for x in range(2,world_width-2):
			var cell := Vector2i(x,y)
			if pond.has(cell) or route.has(cell): continue
			if meadow_contains(Vector2(cell)) or orchard_contains(Vector2(cell)): continue
			var hash_value := absi(x*73856093 ^ y*19349663)
			if hash_value % 17 == 0:
				details.set_cell(cell,19,Vector2i(hash_value%4,0),1+hash_value%8)
			elif hash_value % 31 == 0:
				details.set_cell(cell,19,Vector2i(int(hash_value/7)%4,1),1+hash_value%8)
	build_pond_water_garden()
	nature = Node2D.new()
	nature.y_sort_enabled = true
	own(nature,world,"Nature")
	build_meadow_blooms()
	# Larger hand-painted lily groups sit above the animated water surface.
	for i in range(14):
		var x := roundi(sx(94 + (i*7)%18))
		var y := 21 + (i*11)%16
		if pond.has(Vector2i(x,y)):
			var lily := cluster_from("PondLilyGroup_%02d"%i,Vector2(x,y),PROP_ATLAS,7+i%4,0.62)
			lily.get_node("Artwork").position.y = 0
	build_orchard_grove()
	for i in range(layout.trees.size()):
		var p: Array = layout.trees[i]
		if pond_garden_contains(Vector2(p[0],p[1])) or orchard_contains(Vector2(p[0],p[1])): continue
		tree(Vector2(p[0],p[1]),p[2],"Tree_%02d" % i)
	for i in range(layout.grove_trees.size()):
		var p: Array = layout.grove_trees[i]
		tree(Vector2(p[0],p[1]),p[2],"GroveTree_%02d"%i)
	# Curated boundary belts: staggered spacing with clear gaps inside the world.
	for x in range(1,world_width-1,2):
		var north_cell := Vector2i(x,1+(x%3))
		var south_cell := Vector2i(x,world_height-2-(x%2))
		tree(north_cell,edge_tree_kind(north_cell),"NorthTree_%02d"%x)
		# Looser tree groups frame the meadow instead of a continuous hedge.
		if x < 5 or x > 25 or x%6 == 1:
			tree(south_cell,edge_tree_kind(south_cell),"SouthTree_%02d"%x)
	# A staggered inner canopy row gives the map the framed, enclosed feel of the reference.
	for x in range(2,world_width-2,3):
		var north_inner := Vector2i(x,5+(x%2))
		var south_inner := Vector2i(x,world_height-7-(x%2))
		tree(north_inner,edge_tree_kind(north_inner),"NorthInnerTree_%02d"%x)
		tree(south_inner,edge_tree_kind(south_inner),"SouthInnerTree_%02d"%x)
	for y in range(5,world_height-3,3):
		var west_cell := Vector2i(1+(y%2),y)
		var east_cell := Vector2i(world_width-3+(y%2),y)
		tree(west_cell,edge_tree_kind(west_cell),"WestTree_%02d"%y)
		tree(east_cell,edge_tree_kind(east_cell),"EastTree_%02d"%y)
	for i in range(layout.bushes.size()):
		var p: Array = layout.bushes[i]
		if route.has(Vector2i(p[0],p[1])): continue
		if pond_garden_contains(Vector2(p[0],p[1])) or orchard_contains(Vector2(p[0],p[1])): continue
		low_tree(Vector2(p[0],p[1]),[6,7,0,4][posmod(i*5+p[0]+p[1],4)],"Bush_%02d"%i,0.42 if i%3 else 0.48)
	for i in range(layout.rocks.size()):
		var p: Array = layout.rocks[i]
		if not route_clearance(Vector2i(p[0],p[1])): continue
		if pond_garden_contains(Vector2(p[0],p[1])) or orchard_contains(Vector2(p[0],p[1])): continue
		woodland_prop(Vector2(p[0],p[1]),i%4,"Rock_%02d"%i,0.6,Vector2(9,6))
	for i in range(layout.flower_patches.size()):
		var p: Array = layout.flower_patches[i]
		if meadow_contains(Vector2(p[0],p[1])): continue
		if pond_garden_contains(Vector2(p[0],p[1])): continue
		if orchard_contains(Vector2(p[0],p[1])): continue
		var flower_type := clampi(int(p[2]),0,8)
		var offset_list := [Vector2.ZERO,Vector2(1,0),Vector2(0,1),Vector2(2,1),Vector2(-1,2)]
		for j in range(offset_list.size()):
			var cell: Vector2 = Vector2(p[0],p[1])+offset_list[j]
			if not pond.has(Vector2i(cell)) and not route.has(Vector2i(cell)):
				# Compact clumps repeat native pixel groupings at varied scales.
				flower_clump(cell,flower_type*2+j,"Flower_%02d_%d"%[i,j],0.30)
	for i in range(layout.mushrooms.size()):
		var p: Array = layout.mushrooms[i]
		if route.has(Vector2i(p[0],p[1])): continue
		var cell := Vector2(p[0],p[1])
		if i%3 == 0 and cell.x < 56 and cell.y > 12 and cell.y < 50:
			mushroom_cluster(cell,i*7+int(p[2]),"Mushroom_%02d"%i,0.48)
		else:
			mushroom(cell,p[2],float(p[3]),p[4],"Mushroom_%02d"%i)
	# Large clusters give the western destination the reference image's rich focal canopy.
	var cluster_slots := [[sx(10),23],[sx(17),17],[sx(20),31],[sx(26),20],[sx(27),38],[sx(35),18],[sx(38),37],[sx(43),23],[sx(43),33],[sx(12),37],[sx(24),16],[sx(37),30]]
	for i in range(cluster_slots.size()):
		var cell := Vector2(cluster_slots[i][0],cluster_slots[i][1])
		var clear := true
		for nearby in route:
			if Vector2(nearby).distance_to(cell) < 2.2: clear = false
		if clear: mushroom_cluster(cell,i*5+2,"MushroomCluster_%02d"%i,0.78 if i%3 else 0.88)
	for i in range(layout.logs.size()):
		var p: Array = layout.logs[i]
		if not route_clearance(Vector2i(p[0],p[1])): continue
		woodland_prop(Vector2(p[0],p[1]),12,"Log_%02d"%i,0.62,Vector2(22,7))
	for i in range(layout.stumps.size()):
		var p: Array = layout.stumps[i]
		if not route_clearance(Vector2i(p[0],p[1])): continue
		woodland_prop(Vector2(p[0],p[1]),14,"Stump_%02d"%i,0.58,Vector2(9,6))
	for i in range(layout.creek_reeds.size()):
		var p: Array = layout.creek_reeds[i]
		woodland_prop(Vector2(p[0],p[1]),4+i%3,"CreekReeds_%02d"%i,0.62)
	build_river_reeds()
	build_creekside_clearing()
	build_meadow_accents()
	build_pond_garden_accents()
	build_orchard_approach()
	build_central_green()
	build_destination_approaches()
	build_reference_scatter()
	build_roadside_discoveries()
	build_cottage()
	build_fence()
	build_cottage_garden()
	var boundaries := Node2D.new()
	own(boundaries,world,"WorldBoundaries")
	var world_pixels := Vector2(world_width,world_height)*16.0
	for data in [[Vector2(world_pixels.x,16),Vector2(world_pixels.x/2,-8)],[Vector2(world_pixels.x,16),Vector2(world_pixels.x/2,world_pixels.y+8)],[Vector2(16,world_pixels.y),Vector2(-8,world_pixels.y/2)],[Vector2(16,world_pixels.y),Vector2(world_pixels.x+8,world_pixels.y/2)]]:
		var boundary := Node2D.new()
		own(boundary,boundaries,"Boundary%d"%boundaries.get_child_count())
		rectangle(boundary,data[0],data[1])
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	player.position = Vector2(layout.spawn[0]*16+8,layout.spawn[1]*16+8)
	own(player,nature,"Player")
	await process_frame
	var scene := PackedScene.new()
	var result := scene.pack(world)
	assert(result==OK)
	assert(ResourceSaver.save(scene,"res://scenes/world.tscn")==OK)
	print("Saved editable ",world_width,"x",world_height," world; ",nature.get_child_count()," sorted objects.")
	quit()

func build_roadside_discoveries() -> void:
	# Small authored compositions, not uniform scatter. Alternate trail sides.
	var pockets := layer("RoadsideDiscoveryFlowers")
	pockets.collision_enabled = false
	var stops := [Vector2i(roundi(sx(56)),36), Vector2i(roundi(sx(81)),37), Vector2i(roundi(sx(83)),62), Vector2i(roundi(sx(37)),76), Vector2i(roundi(sx(29)),36), Vector2i(roundi(sx(46)),68)]
	for i in range(stops.size()):
		var center: Vector2i = stops[i]
		for offset in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,1),Vector2i(-2,1),Vector2i(0,2),Vector2i(2,0)]:
			var cell: Vector2i = center + offset
			if not discovery_cell_clear(cell): continue
			pockets.set_cell(cell,19,Vector2i(i % 4, (i / 2) % 2))
		if not discovery_cell_clear(center): continue
		var clear := true
		for existing in nature.get_children():
			if existing.position.distance_to(Vector2(center)*16.0+Vector2(8,8)) < 26.0: clear = false
		if not clear: continue
		if i == 4:
			mushroom_cluster(Vector2(center),8,"TrailDiscoveryMushroom",0.85)
		elif i % 2 == 0:
			woodland_prop(Vector2(center),i%4,"TrailDiscoveryRock_%d"%i,0.58,Vector2(9,6))
		else:
			woodland_prop(Vector2(center),13,"TrailDiscoveryLog_%d"%i,0.6,Vector2(14,5))

func discovery_cell_clear(cell: Vector2i) -> bool:
	if pond.has(cell): return false
	for y in range(-1,2):
		for x in range(-1,2):
			if route.has(cell+Vector2i(x,y)): return false
	return true

func meadow_contains(cell: Vector2) -> bool:
	var bounds: Array = layout.meadow_design.bounds
	return cell.x >= bounds[0] and cell.x < bounds[2] and cell.y >= bounds[1] and cell.y < bounds[3]

func pond_garden_contains(cell: Vector2) -> bool:
	var bounds: Array = layout.pond_garden_clear
	return cell.x >= bounds[0] and cell.x < bounds[2] and cell.y >= bounds[1] and cell.y < bounds[3]

func orchard_contains(cell: Vector2) -> bool:
	var bounds: Array = layout.orchard_bounds
	return cell.x >= bounds[0] and cell.x < bounds[2] and cell.y >= bounds[1] and cell.y < bounds[3]

func build_orchard_approach() -> void:
	# Bake a seeded gradient on the southbound route into the expanded orchard.
	var points: Array[Vector2] = [Vector2(sx(61.6)+19.0,80)]
	for entry in layout.orchard_trail:
		var point := Vector2(entry[0],entry[1])
		if point != points.back(): points.append(point)
	var total_length := 0.0
	for i in range(points.size()-1):
		total_length += points[i].distance_to(points[i+1])
	var rng := RandomNumberGenerator.new()
	rng.seed = 20270526
	var blooms := layer("OrchardApproachBlooms")
	blooms.collision_enabled = false
	var placed_trees: Array[Vector2] = []
	for y in range(62,91):
		for x in range(roundi(sx(51)+19.0),roundi(sx(82)+19.0)):
			var cell := Vector2i(x,y)
			if route.has(cell) or pond.has(cell) or orchard_contains(Vector2(cell)): continue
			var distance := INF
			var progress := 0.0
			var walked := 0.0
			for i in range(points.size()-1):
				var start := points[i]
				var segment := points[i+1]-start
				var t := clampf((Vector2(cell)-start).dot(segment)/segment.length_squared(),0.0,1.0)
				var separation := Vector2(cell).distance_to(start+segment*t)
				if separation < distance:
					distance = separation
					progress = (walked+segment.length()*t)/total_length
				walked += segment.length()
			if distance < 2.5 or distance > 6.0: continue
			# Smoothly blend normal roadside grass into the destination's palette.
			var richness := smoothstep(0.0,1.0,progress)
			var pixel_position := Vector2(cell)*16.0+Vector2(8,8)
			var occupied := false
			for existing in nature.get_children():
				if existing.position.distance_to(pixel_position) < 36.0:
					occupied = true
					break
			if occupied: continue
			if distance > 3.5 and rng.randf() < lerpf(0.025,0.10,richness):
				var clear := true
				for other in placed_trees:
					if other.distance_to(Vector2(cell)) < 4.0: clear = false
				if clear:
					var name := "ApproachTree_%d_%d"%[x,y]
					if rng.randf() < richness*0.85:
						low_tree(Vector2(cell),[0,1,2,4,6,8,10,12][rng.randi_range(0,7)],name,0.62)
					else:
						tree(Vector2(cell),[1,4,6][rng.randi_range(0,2)],name)
					placed_trees.append(Vector2(cell))
					continue
			if rng.randf() < lerpf(0.05,0.38,richness):
				if rng.randf() < richness:
					blooms.set_cell(cell,19,Vector2i(rng.randi_range(0,3),rng.randi_range(0,1)),rng.randi_range(1,8))
				else:
					blooms.set_cell(cell,19,Vector2i(rng.randi_range(0,3),0),rng.randi_range(1,8))
	# A small threshold planting marks the transition into the orchard without
	# filling the orchard's deliberately open interior.
	for cell in [Vector2i(82,79),Vector2i(83,78),Vector2i(84,77),Vector2i(84,81),Vector2i(82,82)]:
		if not route.has(cell) and not pond.has(cell):
			blooms.set_cell(cell,19,Vector2i(posmod(cell.x+cell.y,4),posmod(cell.x,2)),3+posmod(cell.y,5))

func build_destination_approaches() -> void:
	# Independent seeds keep one destination's edits from reshuffling another.
	for design in [
		{"name":"Mushroom", "branch":0, "seed":3101},
		{"name":"Meadow", "branch":3, "seed":3102},
		{"name":"Pond", "branch":1, "seed":3103},
		{"name":"Creek", "branch":2, "seed":3104},
	]:
		build_destination_approach(design)
	build_area_thresholds()

func transition_clear(cell: Vector2, spacing := 24.0) -> bool:
	var cell_key := map_cell(cell)
	if pond.has(cell_key) or not route_clearance(cell_key): return false
	var target := cell * 16.0 + Vector2(8,8)
	if spacing > 0.0:
		for existing in nature.get_children():
			if existing.position.distance_to(target) < spacing: return false
	return true

func build_area_thresholds() -> void:
	# Short, palette-matched compositions make the change of biome readable at
	# each trailhead while leaving the walkable approach and central path open.
	for entry in [[32.0,20.0,4],[31.0,36.0,9],[46.0,18.0,6],[47.0,37.0,13]]:
		var cell := Vector2(entry[0],entry[1])
		if transition_clear(cell,0.0): mushroom_cluster(cell,int(entry[2]),"MushroomThreshold_%02d_%02d"%[int(cell.x),int(cell.y)],0.68)
	for entry in [[58.0,78.0,0],[59.0,82.0,2],[49.0,83.0,3],[47.0,86.0,1],[56.0,88.0,0]]:
		var cell := Vector2(entry[0],entry[1])
		if transition_clear(cell,0.0): flower_clump(cell,int(entry[2])*3+int(cell.x)%4,"MeadowThreshold_%02d_%02d"%[int(cell.x),int(cell.y)],0.48)
	for entry in [[89.0,22.0,4],[90.0,32.0,5],[95.0,35.0,6]]:
		var cell := Vector2(entry[0],entry[1])
		if transition_clear(cell,0.0): woodland_prop(cell,int(entry[2]),"PondThresholdReeds_%02d_%02d"%[int(cell.x),int(cell.y)],0.56)
	for entry in [[93.0,66.0,4],[105.0,65.0,10],[94.0,77.0,14]]:
		var cell := Vector2(entry[0],entry[1])
		if transition_clear(cell,23.0):
			var tree_object := cluster_from("OrchardThresholdTree_%02d_%02d"%[int(cell.x),int(cell.y)],cell,TREE_ATLAS,int(entry[2]),0.96,Vector2(7,6))
			tree_object.get_node("Artwork").position.y -= 2.0
	for entry in [[131.0,66.0,4],[132.0,72.0,6],[131.0,85.0,5],[124.0,70.0,2],[121.0,84.0,3]]:
		var cell := Vector2(entry[0],entry[1])
		if not transition_clear(cell,0.0): continue
		if int(entry[2]) in [4,5,6]: woodland_prop(cell,int(entry[2]),"CreekThresholdReeds_%02d_%02d"%[int(cell.x),int(cell.y)],0.64)
		else: woodland_prop(cell,int(entry[2]),"CreekThresholdStone_%02d_%02d"%[int(cell.x),int(cell.y)],0.58)

func build_destination_approach(design: Dictionary) -> void:
	var points: Array[Vector2] = []
	var minimum := Vector2(INF,INF)
	var maximum := Vector2(-INF,-INF)
	for entry in layout.path_branches[int(design.branch)]:
		var point := Vector2(entry[0],entry[1])
		if not points.is_empty() and point == points.back(): continue
		points.append(point)
		minimum = minimum.min(point)
		maximum = maximum.max(point)
	var length := 0.0
	for i in range(points.size()-1): length += points[i].distance_to(points[i+1])
	var rng := RandomNumberGenerator.new()
	rng.seed = int(design.seed)
	var plants := layer(String(design.name)+"ApproachPlants")
	plants.collision_enabled = false
	var tree_positions: Array[Vector2] = []
	var accent_positions: Array[Vector2] = []
	for y in range(maxi(4,int(minimum.y)-6),mini(int(layout.size[1])-4,int(maximum.y)+7)):
		for x in range(maxi(4,int(minimum.x)-6),mini(int(layout.size[0])-4,int(maximum.x)+7)):
			var cell := Vector2i(x,y)
			var is_meadow_approach := String(design.name) == "Meadow"
			if pond.has(cell) or (meadow_contains(Vector2(cell)) and not is_meadow_approach) or orchard_contains(Vector2(cell)) or pond_garden_contains(Vector2(cell)): continue
			# Protect the complete road network, including nearby junctions.
			var road_clear := true
			for dy in range(-1,2):
				for dx in range(-1,2):
					if route.has(cell+Vector2i(dx,dy)): road_clear = false
			if not road_clear: continue
			var distance := INF
			var progress := 0.0
			var walked := 0.0
			for i in range(points.size()-1):
				var segment := points[i+1]-points[i]
				var t := clampf((Vector2(cell)-points[i]).dot(segment)/segment.length_squared(),0.0,1.0)
				var separation := Vector2(cell).distance_to(points[i]+segment*t)
				if separation < distance:
					distance = separation
					progress = (walked+segment.length()*t)/length
				walked += segment.length()
			if distance < 2.5 or distance > 6.0: continue
			var richness := smoothstep(0.0,1.0,progress)
			var occupied := false
			var pixel_position := Vector2(cell)*16.0+Vector2(8,8)
			for existing in nature.get_children():
				if existing.position.distance_to(pixel_position) < 30.0:
					occupied = true
					break
			if occupied: continue
			# Space canopies generously, with richer destination trees near arrival.
			if distance > 4.0 and rng.randf() < lerpf(0.015,0.065,richness):
				var clear := true
				for other in tree_positions:
					if other.distance_to(Vector2(cell)) < 5.0: clear = false
				if clear:
					var kind := 1
					if rng.randf() < richness:
						kind = {"Mushroom":3,"Meadow":9,"Pond":6,"Creek":11}[String(design.name)]
					tree(Vector2(cell),kind,"%sApproachTree_%d_%d"%[design.name,x,y])
					tree_positions.append(Vector2(cell))
					continue
			var destination_density := 0.46 if String(design.name) == "Meadow" else 0.34
			# Gentle roadside clusters begin early, with quiet gaps between them.
			var pocket := sin(float(x) * 0.47 + float(y) * 0.31) > -0.15
			var early_density := 0.22 if pocket else 0.07
			if rng.randf() > lerpf(early_density,destination_density,richness): continue
			if rng.randf() > richness:
				plants.set_cell(cell,19,Vector2i(rng.randi_range(0,3),0),rng.randi_range(1,8))
			elif String(design.name) == "Mushroom":
				var clear := true
				for other in accent_positions:
					if other.distance_to(Vector2(cell)) < 2.0: clear = false
				if clear:
					mushroom(Vector2(cell),rng.randi_range(0,2),1.0,[0,3,4][rng.randi_range(0,2)],"ApproachMushroom_%d_%d"%[x,y])
					accent_positions.append(Vector2(cell))
			elif String(design.name) in ["Pond","Creek"] and rng.randf() < 0.5:
				var clear := true
				for other in accent_positions:
					if other.distance_to(Vector2(cell)) < 3.0: clear = false
				if clear:
					woodland_prop(Vector2(cell),4+rng.randi_range(0,2),"%sApproachReeds_%d_%d"%[design.name,x,y],0.56)
					accent_positions.append(Vector2(cell))
			else:
				var color := rng.randi_range(0,3) if String(design.name) == "Meadow" else rng.randi_range(2,3)
				plants.set_cell(cell,19,Vector2i(color,rng.randi_range(0,1)),rng.randi_range(1,8))

func build_orchard_grove() -> void:
	for i in range(layout.orchard_trees.size()):
		var entry: Array = layout.orchard_trees[i]
		var orchard_cell := map_cell(Vector2(entry[0],entry[1]))
		# Orchard canopies may shade the trail edge; only keep their trunk collider
		# off the road itself, since this curated ring is intentionally tight.
		if on_painted_path(orchard_cell): continue
		var variety: int = [4,10,14,5][posmod(int(entry[2])+i,4)]
		var orchard_tree := cluster_from("OrchardTree_%02d"%i,Vector2(entry[0],entry[1]),TREE_ATLAS,variety,1.08,Vector2(7,6))
		orchard_tree.get_node("Artwork").position.y -= 3.0
	# The blanket is the quiet focal point under the central shade tree.
	object_from("PicnicBlanket",Vector2(sx(71.4)+19.0,72.0),"res://assets/sprout_lands/picnic_grove.png",Rect2(0,0,48,32))
	object_from("HarvestCrate",Vector2(sx(73.9)+19.0,72.1),"res://assets/sprout_lands/picnic_grove.png",Rect2(48,0,16,16),Vector2(8,6))
	for i in range(layout.orchard_fruit.size()):
		var entry: Array = layout.orchard_fruit[i]
		object_from("FallenFruit_%02d"%i,Vector2(entry[0],entry[1]),"res://assets/sprout_lands/picnic_grove.png",Rect2(64+int(entry[2])*16,0,16,16))
	# A small secondary fruit cluster gives the southern grove a fuller silhouette.
	for i in range(layout.orchard_flowers.size()):
		var entry: Array = layout.orchard_flowers[i]
		var cell := Vector2(entry[0],entry[1])
		if route.has(Vector2i(cell)): continue
		flower_clump(cell,int(entry[2])*3+i,"OrchardFlower_%02d"%i,0.38)
	# Varied fruit trees surround a clear picnic interior.
	for entry in [[sx(57.5)+19.0,65.0,4],[sx(66.5)+19.0,62.0,10],[sx(73.9)+19.0,67.0,14],[sx(81.2)+19.0,69.0,4],[sx(65.7)+19.0,80.0,10],[sx(79.6)+19.0,80.0,14]]:
		var cell := Vector2(entry[0],entry[1])
		if on_painted_path(map_cell(cell)): continue
		cluster_from("OrchardTreeAccent_%02d_%02d"%[int(cell.x),int(cell.y)],cell,TREE_ATLAS,int(entry[2]),1.08,Vector2(7,6))
	# Fill the picnic grove interior with a loose ring of fruit trees around open grass.
	for entry in [[91,67,4],[97,71,10],[102,65,14],[109,67,5],[117,70,4],[123,74,10],[119,80,14],[110,82,5],[100,80,4],[92,77,10],[106,75,14]]:
		var cell := Vector2(entry[0],entry[1])
		if on_painted_path(map_cell(cell)): continue
		cluster_from("OrchardInteriorTree_%02d_%02d"%[int(cell.x),int(cell.y)],cell,TREE_ATLAS,int(entry[2]),1.08,Vector2(7,6))

func build_reference_scatter() -> void:
	# Light tree and stone groupings restore the small discoveries visible in the reference lawn.
	for entry in [[52,38,0],[59,35,1],[66,39,4],[77,43,1],[82,50,0],[57,56,6],[78,57,2],[91,50,4],[104,49,1],[55,32,4],[65,34,0],[84,40,2],[92,46,1],[108,43,6],[63,56,3],[83,58,4],[97,54,2],[113,51,0],[74,38,6]]:
		var cell := Vector2(entry[0],entry[1])
		if pond.has(Vector2i(cell)) or orchard_contains(cell) or meadow_contains(cell): continue
		tree(cell,int(entry[2]),"ReferenceLawnTree_%02d_%02d"%[entry[0],entry[1]])
	for entry in [[55,36,0],[70,43,1],[80,52,2],[93,47,0],[52,58,1],[74,60,2],[102,52,1],[57,42,2],[69,34,0],[88,52,1],[105,57,2],[79,45,1],[64,50,0]]:
		var cell := Vector2(entry[0],entry[1])
		if route_clearance(Vector2i(cell)) and not pond.has(Vector2i(cell)) and not orchard_contains(cell) and not meadow_contains(cell):
			woodland_prop(cell,int(entry[2]),"ReferenceLawnStone_%02d_%02d"%[entry[0],entry[1]],0.48,Vector2(7,4))
	for entry in [[54,44,2],[69,47,6],[84,53,4],[95,46,7],[62,60,1],[80,61,3],[58,36,5],[73,41,0],[90,45,6],[110,51,2],[69,56,1],[85,59,4],[98,43,3]]:
		var cell := Vector2(entry[0],entry[1])
		if route_clearance(Vector2i(cell)) and not pond.has(Vector2i(cell)) and not orchard_contains(cell) and not meadow_contains(cell):
			flower_clump(cell,int(entry[2])*2+int(cell.x)%4,"ReferenceLawnFlower_%02d_%02d"%[entry[0],entry[1]],0.38)

func build_pond_water_garden() -> void:
	var plants := layer("PondGardenPlants")
	plants.collision_enabled = false
	for entry in layout.pond_lilies:
		var cell := Vector2i(entry[0],entry[1])
		if pond.has(cell):
			plants.set_cell(cell,int(entry[2]),Vector2i(entry[3],entry[4]))
	for entry in layout.pond_garden_flowers:
		var cell := Vector2i(entry[0],entry[1])
		if not pond.has(cell) and not route.has(cell):
			plants.set_cell(cell,19,Vector2i(entry[2],entry[3]),1+(cell.x*7+cell.y*3)%8)

func pond_dragonfly(cell: Vector2, color_row: int, index: int) -> void:
	var object := Node2D.new()
	object.position = cell*16.0+Vector2(8,3)
	own(object,nature,"PondDragonfly_%02d"%index)
	var sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default",7.0+color_row)
	frames.set_animation_loop("default",true)
	var texture: Texture2D = load("res://assets/sprout_lands/pond_life.png")
	for frame in range(4):
		var region := AtlasTexture.new()
		region.atlas = texture
		region.region = Rect2(frame*16,color_row*16,16,16)
		frames.add_frame("default",region)
	sprite.sprite_frames = frames
	sprite.frame = index%4
	sprite.autoplay = "default"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	own(sprite,object,"Flutter")

func build_pond_garden_accents() -> void:
	for i in range(layout.pond_reeds.size()):
		var entry: Array = layout.pond_reeds[i]
		woodland_prop(Vector2(entry[0],entry[1]),4+i%3,"PondReeds_%02d"%i,0.58)
	for i in range(layout.pond_dragonflies.size()):
		var entry: Array = layout.pond_dragonflies[i]
		pond_dragonfly(Vector2(entry[0],entry[1]),int(entry[2]),i)
	# A natural log and flat stone make the east bank a quiet viewing spot.
	woodland_prop(Vector2(sx(113.0),36.0),11,"PondGardenBench",0.7,Vector2(18,6))
	woodland_prop(Vector2(sx(115.0),38.0),1,"PondGardenSeat",0.55,Vector2(9,6))
	var bridge := object_from("PondGardenFootbridge",Vector2(sx(102),19),"res://assets/innate/creek_footbridge.png",Rect2(0,0,128,64))
	bridge.get_node("Artwork").texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func build_meadow_blooms() -> void:
	# Curved flower drifts create broad color bands, with visible grass between
	# clusters and a clear opening around both meadow trails.
	var bounds: Array = layout.meadow_design.bounds
	var first_x := int(bounds[0]) + 2
	var last_x := int(bounds[2]) - 2
	var grid_index := 0
	var cluster_centers: Array[Vector2] = []
	for x in range(first_x,last_x,2):
		var progress := inverse_lerp(float(first_x),float(last_x),float(x))
		var spine_y := lerpf(68.0,88.0,progress)+sin(float(x)*0.31)*1.4+sin(float(x)*0.13)*0.9
		for row in range(-2,3):
			var jitter := posmod(x*17 + row*29,3) - 1
			var cell := Vector2(x + posmod(row + x,2), spine_y + row*2.15 + jitter*0.45)
			var across := absf(cell.y-spine_y)
			if across > 5.0 or not meadow_contains(cell): continue
			var center := Vector2i(roundi(cell.x),roundi(cell.y))
			if pond.has(center): continue
			var hash_value := absi(int(cell.x)*73856093 ^ int(cell.y)*19349663 ^ 83492791)
			var density := lerpf(0.82,0.18,clampf(across/5.0,0.0,1.0))
			if float(hash_value%100)/100.0 > density: continue
			var clear := true
			for dy in range(-2,3):
				for dx in range(-2,3):
					if route.has(center+Vector2i(dx,dy)): clear = false
			if not clear: continue
			var scale_factor := 0.38 + float(hash_value%15)/100.0
			flower_clump(cell,hash_value%16,"MeadowDrift_%03d"%grid_index,scale_factor)
			cluster_centers.append(cell)
			grid_index += 1
	# Small single blooms fill the gaps between large drifts without turning the
	# meadow into a solid carpet or covering either trail.
	var detail_index := 0
	for x in range(first_x,last_x):
		var progress := inverse_lerp(float(first_x),float(last_x),float(x))
		var spine_y := lerpf(68.0,88.0,progress)+sin(float(x)*0.31)*1.4+sin(float(x)*0.13)*0.9
		for row in range(-2,3):
			var cell := Vector2(x,spine_y+row*2.8)
			if not meadow_contains(cell): continue
			var center := map_cell(cell)
			if pond.has(center) or not route_clearance(center): continue
			var hash_value := absi(int(cell.x)*19349663 ^ int(cell.y)*83492791 ^ 4729183)
			if hash_value%100 > 34: continue
			var overlaps_cluster := false
			for cluster in cluster_centers:
				if cluster.distance_to(cell) < 2.1:
					overlaps_cluster = true
					break
			if overlaps_cluster: continue
			flower_detail(cell,hash_value%16,"MeadowSingleBloom_%03d"%detail_index,0.36+float(hash_value%13)/100.0)
			detail_index += 1

func build_meadow_accents() -> void:
	# A handful of taller flowers act as individual landmarks beside the drifts.
	var accents := [
		[Vector2(sx(12.0),69.2),0], [Vector2(sx(17.4),75.6),1],
		[Vector2(sx(22.2),82.0),3], [Vector2(sx(28.7),85.8),1],
		[Vector2(sx(34.2),89.0),2], [Vector2(sx(40.5),92.8),0],
		[Vector2(sx(45.0),96.1),3], [Vector2(sx(11.2),84.1),2],
		[Vector2(sx(31.0),94.1),1],
	]
	for i in range(accents.size()):
		var entry: Array = accents[i]
		var cell: Vector2 = entry[0]
		if route.has(Vector2i(cell)) or pond.has(Vector2i(cell)): continue
		flower_clump(cell,int(entry[1])*4+i,"MeadowAccent_%02d"%i,0.62)
	woodland_prop(Vector2(24.0,84.0),1,"MeadowRestStone",0.52)

func build_creekside_clearing() -> void:
	# A roomy river landing gives the east edge a clear place to pause and explore.
	var bridge := object_from("CreekFootbridge",Vector2(sx(116),80),"res://assets/innate/creek_footbridge.png",Rect2(0,0,128,64))
	bridge.get_node("Artwork").texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if route_clearance(Vector2i(sx(104.2),77.4)):
		woodland_prop(Vector2(sx(104.2),77.4),11,"CreeksideLogSeat",0.7,Vector2(18,6))
	if route_clearance(Vector2i(sx(106.0),78.4)):
		woodland_prop(Vector2(sx(106.0),78.4),2,"CreeksideBankStone",0.58,Vector2(9,6))
	if route_clearance(Vector2i(sx(105.6),80.0)):
		woodland_prop(Vector2(sx(105.6),80.0),0,"CreeksideShoreRock",0.52,Vector2(8,5))
	if route_clearance(Vector2i(sx(104.0),79.5)):
		woodland_prop(Vector2(sx(104.0),79.5),3,"CreeksideShoreStone",0.5,Vector2(8,5))
	woodland_prop(Vector2(sx(101.2),75.4),15,"CreeksideTrailMarker",0.62)
	# A little creekside bed makes the crossing legible before you step onto it.
	for entry in [[sx(104.0),73.0,4],[sx(107.0),73.6,7],[sx(109.2),83.5,5],[sx(105.8),84.2,2],[sx(121.0),76.0,1],[sx(121.5),84.0,6]]:
		var cell := Vector2(entry[0],entry[1])
		if route.has(Vector2i(cell)) or pond.has(Vector2i(cell)): continue
		flower_clump(cell,int(entry[2])*3+int(cell.x)%4,"CreekFlower_%02d_%02d"%[int(cell.x),int(cell.y)],0.44)

func build_central_green() -> void:
	# A shade tree and bench form the garden's quiet side destination.
	tree(Vector2(sx(61),52),0,"CentralGreenShadeTree")
	woodland_prop(Vector2(sx(62.0),54.4),12,"CentralGreenBench",0.68)
	woodland_prop(Vector2(sx(65.0),52.0),1,"CentralGreenStone",0.56)
	for entry in [[sx(57.0),49.0,3],[sx(66.0),49.0,6],[sx(67.0),54.0,1],[sx(55.0),56.0,5]]:
		var cell := Vector2(entry[0],entry[1])
		if not route_clearance(Vector2i(cell)): continue
		flower_clump(cell,int(entry[2])*3+int(cell.x)%4,"GreenFlower_%02d_%02d"%[int(cell.x),int(cell.y)],0.42)

func build_cottage() -> void:
	var cottage := Node2D.new()
	var cottage_cell: Array = layout.cottage
	cottage.position = Vector2(cottage_cell[0]*16+8,cottage_cell[1]*16+8)
	own(cottage,nature,"Cottage")
	var artwork := Sprite2D.new()
	artwork.texture = load("res://assets/innate/cottage.png")
	artwork.scale = Vector2(1.5,1.5)
	# Lower the sprite so the cottage sits in the central clearing, as in the reference.
	artwork.position.y = -48.0
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	own(artwork,cottage,"Artwork")
	rectangle(cottage,Vector2(76,42),Vector2(8,-9))
	var step := layer("Doorstep")
	step.set_cell(Vector2i(cottage_cell[0],cottage_cell[1]+1),5,Vector2i(0,4))

func build_fence() -> void:
	# A centered north and south gate align the cottage door with the garden path.
	var garden: Array = layout.garden
	var west: int = garden[0]-1
	var east: int = garden[2]+1
	var north: int = garden[1]-1
	var gate_center: int = int((garden[0]+garden[2])/2)
	fence_piece(Vector2i(west,north),Vector2i(1,0))
	fence_piece(Vector2i(east,north),Vector2i(3,0))
	for x in range(west+1,east):
		if x >= gate_center-1 and x <= gate_center+1: continue
		fence_piece(Vector2i(x,north),Vector2i(2,0))
	for x in range(west,east+1):
		if x >= gate_center-1 and x <= gate_center+1: continue
		fence_piece(Vector2i(x,garden[3]+1),Vector2i(1 if x==west else (3 if x==east else 2),3))
	for y in range(garden[1],garden[3]+1):
		fence_piece(Vector2i(west,y),Vector2i(0,1))
		fence_piece(Vector2i(east,y),Vector2i(0,1))

func build_cottage_garden() -> void:
	var garden: Array = layout.garden
	# Full, tidy flower rows flank the centered doorway walk, like the chosen mockup.
	var beds := [
		[float(garden[0])+0.9,float(garden[1])+1.5],
		[float(garden[0])+3.0,float(garden[1])+1.5],
		[float(garden[2])-3.0,float(garden[1])+1.5],
		[float(garden[2])-0.9,float(garden[1])+1.5],
		[float(garden[0])+0.9,float(garden[1])+3.7],
		[float(garden[0])+3.0,float(garden[1])+3.7],
		[float(garden[2])-3.0,float(garden[1])+3.7],
		[float(garden[2])-0.9,float(garden[1])+3.7],
	]
	for i in range(beds.size()):
		var cell := Vector2(float(beds[i][0]),float(beds[i][1]))
		flower_clump(cell,i*3+2,"CottageGardenFlower_%02d"%i,0.50 if i%3==0 else 0.46)
	# The flowering trellis anchors the garden's east bed without narrowing the gate.
	var trellis := Node2D.new()
	trellis.position = Vector2((float(garden[2])-0.25)*16.0, (float(garden[1])+3.0)*16.0+8.0)
	own(trellis,nature,"CottageFlowerTrellis")
	var trellis_art := Sprite2D.new()
	trellis_art.texture = load("res://assets/innate/cottage_trellis.png")
	trellis_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trellis_art.scale = Vector2.ONE*0.72
	trellis_art.position.y = -72.0*0.72/2.0
	own(trellis_art,trellis,"Artwork")
	rectangle(trellis,Vector2(9,5))

func fence_piece(cell: Vector2i, atlas: Vector2i) -> void:
	var post := Node2D.new()
	post.position = Vector2(cell*16)+Vector2(8,12)
	own(post,nature,"Fence_%d_%d"%[cell.x,cell.y])
	var artwork := layer("Artwork",post)
	artwork.position = Vector2(-8,-12)
	artwork.set_cell(Vector2i.ZERO,3,atlas)
	rectangle(post,Vector2(14,5))
