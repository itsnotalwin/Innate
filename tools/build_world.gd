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

const TREE_ASSETS := [
	{"texture": "nature.png", "region": Rect2(0, 0, 16, 32)},
	{"texture": "nature.png", "region": Rect2(16, 0, 32, 32)},
	{"texture": "nature.png", "region": Rect2(48, 0, 32, 32)},
	{"texture": "foliage/trees_stumps_bushes_v2.png", "region": Rect2(96, 0, 48, 48)},
	{"texture": "foliage/trees_stumps_bushes_v2.png", "region": Rect2(64, 16, 32, 32)},
	{"texture": "foliage/trees_stumps_bushes_v2.png", "region": Rect2(0, 80, 32, 32)},
	{"texture": "foliage/birch_biome.png", "region": Rect2(112, 0, 48, 48)},
	{"texture": "foliage/birch_biome.png", "region": Rect2(64, 16, 16, 32)},
	{"texture": "foliage/cherry_blossom_biome.png", "region": Rect2(112, 0, 48, 48)},
	{"texture": "foliage/cherry_blossom_biome.png", "region": Rect2(80, 16, 32, 32)},
	{"texture": "pine_biome.png", "region": Rect2(112, 0, 48, 48)},
	{"texture": "pine_biome.png", "region": Rect2(80, 16, 32, 32)},
	{"texture": "foliage/trees_stumps_bushes_v2.png", "region": Rect2(32, 80, 32, 32)},
]

const BUSH_ASSETS := [
	{"texture": "nature.png", "region": Rect2(0, 48, 16, 16)},
	{"texture": "nature.png", "region": Rect2(16, 48, 16, 16)},
]

func _initialize() -> void:
	call_deferred("build")

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

func paint_path(points: Array, radius := 1, bridge_diagonals := false) -> void:
	for i in range(points.size()-1):
		var start := Vector2(points[i][0],points[i][1])
		var end := Vector2(points[i+1][0],points[i+1][1])
		var steps := maxi(1, int(start.distance_to(end)*3))
		var previous := Vector2i(roundi(start.x),roundi(start.y))
		for step in range(steps+1):
			var p := start.lerp(end, float(step)/steps)
			var cell := Vector2i(roundi(p.x),roundi(p.y))
			if bridge_diagonals:
				# Two cells across give the terrain atlas room for continuous corners.
				for offset in [Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
					route[cell+offset] = true
			if bridge_diagonals and cell.x != previous.x and cell.y != previous.y:
				route[Vector2i(previous.x,cell.y)] = true
			for dy in range(-radius,radius+1):
				for dx in range(-radius,radius+1):
					route[Vector2i(roundi(p.x)+dx,roundi(p.y)+dy)] = true
			previous = cell

func object_from(node_name: String, cell: Vector2, texture_path: String, region: Rect2, solid_size := Vector2.ZERO) -> Node2D:
	var object := Node2D.new()
	object.position = cell * 16.0 + Vector2(8, 8)
	own(object, nature, node_name)
	var sprite := Sprite2D.new()
	sprite.texture = load(texture_path if texture_path.begins_with("res://") else "res://assets/sprout_lands/" + texture_path)
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.position.y = -region.size.y / 2.0 + 4.0
	own(sprite, object, "Artwork")
	if solid_size != Vector2.ZERO:
		rectangle(object, solid_size)
	return object

func object_at(node_name: String, cell: Vector2, region: Rect2, solid_size := Vector2.ZERO) -> Node2D:
	return object_from(node_name, cell, "nature.png", region, solid_size)

func tree(cell: Vector2, kind: int, node_name: String) -> void:
	var asset: Dictionary = TREE_ASSETS[posmod(kind, TREE_ASSETS.size())]
	object_from(node_name, cell, String(asset["texture"]), asset["region"], Vector2(7, 7))

func edge_tree_kind(cell: Vector2i) -> int:
	var selector := absi(cell.x * 17 + cell.y * 31)
	if cell.x >= 68 and cell.y <= 43:
		return [10, 11, 10, 6][selector % 4]
	if cell.x >= 32 and cell.x <= 60 and cell.y <= 23:
		return [8, 9, 6, 3][selector % 4]
	if cell.y >= 54:
		return [3, 4, 5, 12][selector % 4]
	if cell.y <= 22:
		return [3, 6, 7, 1][selector % 4]
	return [0, 1, 2, 3, 4, 6][selector % 6]

func mushroom(cell: Vector2, variant: int, scale_factor: float, tint: int, node_name: String) -> void:
	var object := Node2D.new()
	object.position = cell * 16.0 + Vector2(8,8)
	own(object,nature,node_name)
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprout_lands/mushroom_variants.png")
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE*scale_factor
	sprite.position.y = 4.0 - 8.0*scale_factor
	sprite.region_rect = Rect2((variant%3)*16,clampi(tint,0,5)*16,16,16)
	own(sprite,object,"Artwork")

func build() -> void:
	layout = JSON.parse_string(FileAccess.get_file_as_string("res://tools/world_layout.json"))
	world.name = "World"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(world)
	water = layer("Water")
	ground = layer("Ground")
	paths = layer("Paths")
	details = layer("GroundDetails")
	for row in layout.pond_rows:
		for x in range(row[1], row[2]+1):
			pond[Vector2i(x,row[0])] = true
	# Water extends under transparent shoreline pixels; only open water has physics.
	for cell in pond:
		water.set_cell(cell, 2, Vector2i((cell.x+cell.y)%4,0))
	var shore_water := layer("ShoreUnderlay")
	world.move_child(shore_water, 0)
	shore_water.collision_enabled = false
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
	for branch in layout.path_branches:
		paint_path(branch)
	# A light footpath circles the flower clearing and rejoins the south trail.
	paint_path(layout.meadow_trail,0,true)
	# A narrow footpath links the cottage apron to the garden gate.
	paint_path(layout.garden_access,0)
	# A footpath follows the west bank into the creekside rest clearing.
	paint_path(layout.creek_trail,0)
	# A slim loop makes the pond garden a destination from the main road.
	paint_path(layout.pond_garden_trail,0,true)
	# A subtle spur opens a side clearing in the mushroom grove.
	paint_path(layout.mushroom_trail,0)
	# An apron joins the cottage door to the main path.
	var cottage: Array = layout.cottage
	for y in range(cottage[1]+1,cottage[1]+6):
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
			if meadow_contains(Vector2(cell)): continue
			var hash_value := absi(x*73856093 ^ y*19349663)
			if hash_value % 13 == 0:
				details.set_cell(cell,0,Vector2i(hash_value%3,5+(hash_value%2)))
			elif hash_value % 19 == 0:
				details.set_cell(cell,0,Vector2i(6+hash_value%2,5+hash_value%2))
			elif hash_value % 31 == 0:
				details.set_cell(cell,0,Vector2i(8+hash_value%2,5))
	build_meadow_blooms()
	build_pond_water_garden()
	var garden: Array = layout.garden
	var garden_cells: Array[Vector2i] = []
	for y in range(garden[1],garden[3]+1):
		for x in range(garden[0],garden[2]+1): garden_cells.append(Vector2i(x,y))
	paths.set_cells_terrain_connect(garden_cells,0,1)
	var plants := layer("GardenFlowers")
	# Two compact crop beds flank the garden's clear center path.
	for y in [48,50]:
		for x in range(garden[0]+1,garden[0]+4):
			plants.set_cell(Vector2i(x,y),4,Vector2i(3 if (x+y)%2==0 else 4,1))
		for x in range(garden[0]+5,garden[2]):
			plants.set_cell(Vector2i(x,y),4,Vector2i(4 if (x+y)%2==0 else 3,1))
	nature = Node2D.new()
	nature.y_sort_enabled = true
	own(nature,world,"Nature")
	for i in range(layout.trees.size()):
		var p: Array = layout.trees[i]
		if pond_garden_contains(Vector2(p[0],p[1])): continue
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
	for y in range(5,world_height-3,3):
		var west_cell := Vector2i(1+(y%2),y)
		var east_cell := Vector2i(world_width-3+(y%2),y)
		tree(west_cell,edge_tree_kind(west_cell),"WestTree_%02d"%y)
		tree(east_cell,edge_tree_kind(east_cell),"EastTree_%02d"%y)
	for i in range(layout.bushes.size()):
		var p: Array = layout.bushes[i]
		if pond_garden_contains(Vector2(p[0],p[1])): continue
		var asset: Dictionary = BUSH_ASSETS[posmod(i*5+p[0]+p[1], BUSH_ASSETS.size())]
		object_from("Bush_%02d"%i,Vector2(p[0],p[1]),String(asset["texture"]),asset["region"])
	for i in range(layout.rocks.size()):
		var p: Array = layout.rocks[i]
		if pond_garden_contains(Vector2(p[0],p[1])): continue
		object_at("Rock_%02d"%i,Vector2(p[0],p[1]),Rect2(80,64,16,16),Vector2(11,7))
	for i in range(layout.flower_patches.size()):
		var p: Array = layout.flower_patches[i]
		if meadow_contains(Vector2(p[0],p[1])): continue
		if pond_garden_contains(Vector2(p[0],p[1])): continue
		var flower_type := clampi(int(p[2]),0,8)
		var offset_list := [Vector2.ZERO,Vector2(1,0),Vector2(0,1),Vector2(2,1),Vector2(-1,2)]
		for j in range(offset_list.size()):
			var cell: Vector2 = Vector2(p[0],p[1])+offset_list[j]
			if not pond.has(Vector2i(cell)) and not route.has(Vector2i(cell)):
				object_at("Flower_%02d_%d"%[i,j],cell,Rect2(flower_type*16,48,16,16))
	for i in range(layout.mushrooms.size()):
		var p: Array = layout.mushrooms[i]
		mushroom(Vector2(p[0],p[1]),p[2],float(p[3]),p[4],"Mushroom_%02d"%i)
	for i in range(layout.logs.size()):
		var p: Array = layout.logs[i]
		object_at("Log_%02d"%i,Vector2(p[0],p[1]),Rect2(0,64,32,16),Vector2(22,7))
	for i in range(layout.stumps.size()):
		var p: Array = layout.stumps[i]
		object_at("Stump_%02d"%i,Vector2(p[0],p[1]),Rect2(64,32,16,16),Vector2(9,6))
	for i in range(layout.creek_reeds.size()):
		var p: Array = layout.creek_reeds[i]
		var reeds := Sprite2D.new()
		reeds.texture = load("res://assets/sprout_lands/creek_reeds.png")
		reeds.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		reeds.position = Vector2(p[0]*16+8,p[1]*16+4)
		own(reeds,nature,"CreekReeds_%02d"%i)
	build_meadow_accents()
	build_pond_garden_accents()
	build_cottage()
	build_fence()
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

func meadow_contains(cell: Vector2) -> bool:
	var bounds: Array = layout.meadow_design.bounds
	return cell.x >= bounds[0] and cell.x < bounds[2] and cell.y >= bounds[1] and cell.y < bounds[3]

func pond_garden_contains(cell: Vector2) -> bool:
	var bounds: Array = layout.pond_garden_clear
	return cell.x >= bounds[0] and cell.x < bounds[2] and cell.y >= bounds[1] and cell.y < bounds[3]

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
		var texture := "foliage/birch_water_plants.png" if int(entry[2]) == 0 else "foliage/pine_water_plants.png"
		object_from("PondReeds_%02d"%i,Vector2(entry[0],entry[1]),texture,Rect2(16,0,16,16))
	for i in range(layout.pond_dragonflies.size()):
		var entry: Array = layout.pond_dragonflies[i]
		pond_dragonfly(Vector2(entry[0],entry[1]),int(entry[2]),i)
	# A natural log and flat stone make the east bank a quiet viewing spot.
	object_at("PondGardenBench",Vector2(74.0,34.8),Rect2(0,64,32,16),Vector2(22,7))
	object_at("PondGardenSeat",Vector2(71.0,36.8),Rect2(80,64,16,16),Vector2(11,7))

func build_meadow_blooms() -> void:
	# Low, coordinated flower clumps build a carpet without adding runtime objects.
	var blooms := layer("MeadowBlooms")
	blooms.collision_enabled = false
	var design: Dictionary = layout.meadow_design
	var bounds: Array = design.bounds
	var quiet: Array = design.quiet_spot
	for y in range(bounds[1],bounds[3]):
		for x in range(bounds[0],bounds[2]):
			var cell := Vector2i(x,y)
			if pond.has(cell) or route.has(cell): continue
			if Vector2(cell).distance_to(Vector2(quiet[0],quiet[1])) < float(quiet[2]): continue
			var hash_value := absi(x*83492791 ^ y*297121507)
			var best_edge := 2.0
			var color := -1
			for drift in design.drifts:
				var center := Vector2(drift.center[0],drift.center[1])
				var radius := Vector2(drift.radius[0],drift.radius[1])
				var delta := Vector2(cell)-center
				var edge := (delta.x*delta.x)/(radius.x*radius.x)+(delta.y*delta.y)/(radius.y*radius.y)
				edge += float(hash_value%7-3)*0.05
				if edge < best_edge:
					best_edge = edge
					color = int(drift.color)
			if best_edge >= 1.0: continue
			if hash_value%10 < (1 if best_edge < 0.6 else 3): continue
			# Orange and yellow gently mingle; cool blooms remain smaller accents.
			if color <= 1 and hash_value%11 == 0: color = 1-color
			var shape_choice := int(hash_value/97.0)%13
			var row := 1 if shape_choice < 7 else (0 if shape_choice < 9 else (2 if shape_choice < 12 else 3))
			var variation := 1+int(hash_value/389.0)%8
			blooms.set_cell(cell,19,Vector2i(color,row),variation)

func build_meadow_accents() -> void:
	# A few higher blooms break up the low carpets; all use the same 16px palette.
	var accents := [
		[Vector2(7.4,55.6),0], [Vector2(9.2,57.5),0],
		[Vector2(10.5,55.3),1], [Vector2(6.5,57.0),0],
		[Vector2(16.3,54.8),1], [Vector2(18.5,55.5),1],
		[Vector2(19.4,58.6),2], [Vector2(21.7,60.6),2],
		[Vector2(23.8,58.2),2], [Vector2(6.4,62.5),3],
		[Vector2(8.7,64.4),3], [Vector2(5.8,64.1),3],
		[Vector2(14.3,64.2),0], [Vector2(17.6,63.8),1],
		[Vector2(16.3,66.1),0], [Vector2(20.6,65.4),1],
		[Vector2(22.6,66.0),2], [Vector2(14.0,58.0),1],
	]
	for i in range(accents.size()):
		var entry: Array = accents[i]
		var cell: Vector2 = entry[0]
		if route.has(Vector2i(cell)) or pond.has(Vector2i(cell)): continue
		var region := Rect2(int(entry[1])*16,48,16,16)
		var object := object_from("MeadowAccent_%02d"%i,cell,"res://assets/wildflowers/meadow/flowers.png",region)
		object.get_node("Artwork").texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	object_at("MeadowRestStone",Vector2(14.0,61.8),Rect2(80,64,16,16))

func build_cottage() -> void:
	var cottage := Node2D.new()
	var cottage_cell: Array = layout.cottage
	cottage.position = Vector2(cottage_cell[0]*16+8,cottage_cell[1]*16+8)
	own(cottage,nature,"Cottage")
	var walls := layer("Walls",cottage)
	for x in range(-2,3):
		for y in range(-2,1):
			var atlas_x := 0 if x==-2 else (2 if x==2 else 1)
			walls.set_cell(Vector2i(x,y),5,Vector2i(atlas_x,y+3))
	walls.set_cell(Vector2i(0,0),5,Vector2i(3,1))
	walls.set_cell(Vector2i(-1,-1),5,Vector2i(1,0))
	walls.set_cell(Vector2i(1,-1),5,Vector2i(1,0))
	var roof := layer("Roof",cottage)
	roof.position.y = 10.0
	for x in range(-2,3):
		for y in range(-5,-2):
			roof.set_cell(Vector2i(x,y),5,Vector2i(4 if x==-2 else (6 if x==2 else 5),0 if y==-5 else (1 if y==-4 else 4)))
	rectangle(cottage,Vector2(76,42),Vector2(8,-9))
	var step := layer("Doorstep")
	step.set_cell(Vector2i(cottage_cell[0],cottage_cell[1]+1),5,Vector2i(0,4))

func build_fence() -> void:
	# A three-cell north opening lines up with the cottage garden footpath.
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
		fence_piece(Vector2i(x,garden[3]+1),Vector2i(1 if x==west else (3 if x==east else 2),3))
	for y in range(garden[1],garden[3]+1):
		fence_piece(Vector2i(west,y),Vector2i(0,1))
		fence_piece(Vector2i(east,y),Vector2i(0,1))

func fence_piece(cell: Vector2i, atlas: Vector2i) -> void:
	var post := Node2D.new()
	post.position = Vector2(cell*16)+Vector2(8,12)
	own(post,nature,"Fence_%d_%d"%[cell.x,cell.y])
	var artwork := layer("Artwork",post)
	artwork.position = Vector2(-8,-12)
	artwork.set_cell(Vector2i.ZERO,3,atlas)
	rectangle(post,Vector2(14,5))
