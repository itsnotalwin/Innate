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

func paint_path(points: Array) -> void:
	for i in range(points.size()-1):
		var start := Vector2(points[i][0],points[i][1])
		var end := Vector2(points[i+1][0],points[i+1][1])
		var steps := maxi(1, int(start.distance_to(end)*3))
		for step in range(steps+1):
			var p := start.lerp(end, float(step)/steps)
			for dy in range(-1,2):
				for dx in range(-1,2):
					route[Vector2i(roundi(p.x)+dx,roundi(p.y)+dy)] = true

func object_at(node_name: String, cell: Vector2, region: Rect2, solid_size := Vector2.ZERO) -> Node2D:
	var object := Node2D.new()
	object.position = cell * 16.0 + Vector2(8, 8)
	own(object, nature, node_name)
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprout_lands/nature.png")
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.position.y = -region.size.y / 2.0 + 4.0
	own(sprite, object, "Artwork")
	if solid_size != Vector2.ZERO:
		rectangle(object, solid_size)
	return object

func tree(cell: Vector2, kind: int, node_name: String) -> void:
	var regions := [Rect2(0,0,16,32),Rect2(16,0,32,32),Rect2(48,0,32,32)]
	object_at(node_name, cell, regions[kind], Vector2(7,7))

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
	# An apron joins the cottage door to the main path.
	var cottage: Array = layout.cottage
	for y in range(cottage[1]+1,cottage[1]+6):
		for x in range(cottage[0]-2,cottage[0]+4): route[Vector2i(x,y)] = true
	var path_cells: Array[Vector2i] = []
	for cell in route:
		if not pond.has(cell): path_cells.append(cell)
	paths.set_cells_terrain_connect(path_cells, 0, 1)
	# Ground variation follows fixed meadow patches rather than random objects.
	for y in range(2,world_height-2):
		for x in range(2,world_width-2):
			var cell := Vector2i(x,y)
			if pond.has(cell) or route.has(cell): continue
			var hash_value := absi(x*73856093 ^ y*19349663)
			if hash_value % 13 == 0:
				details.set_cell(cell,0,Vector2i(hash_value%3,5+(hash_value%2)))
			elif hash_value % 19 == 0:
				details.set_cell(cell,0,Vector2i(6+hash_value%2,5+hash_value%2))
			elif hash_value % 31 == 0:
				details.set_cell(cell,0,Vector2i(8+hash_value%2,5))
	var garden: Array = layout.garden
	var garden_cells: Array[Vector2i] = []
	for y in range(garden[1],garden[3]+1):
		for x in range(garden[0],garden[2]+1): garden_cells.append(Vector2i(x,y))
	paths.set_cells_terrain_connect(garden_cells,0,1)
	var plants := layer("GardenFlowers")
	for y in range(36,39,2):
		for x in range(15,23,2):
			plants.set_cell(Vector2i(x,y),4,Vector2i(3 if x%4==1 else 4,1))
	nature = Node2D.new()
	nature.y_sort_enabled = true
	own(nature,world,"Nature")
	for i in range(layout.trees.size()):
		var p: Array = layout.trees[i]
		tree(Vector2(p[0],p[1]),p[2],"Tree_%02d" % i)
	# Curated boundary belts: staggered spacing with clear gaps inside the world.
	for x in range(1,world_width-1,2):
		tree(Vector2(x,1+(x%3)),x%3,"NorthTree_%02d"%x)
		tree(Vector2(x,world_height-2-(x%2)),(x+1)%3,"SouthTree_%02d"%x)
	for y in range(5,world_height-3,3):
		tree(Vector2(1+(y%2),y),y%3,"WestTree_%02d"%y)
		tree(Vector2(world_width-3+(y%2),y),(y+1)%3,"EastTree_%02d"%y)
	for i in range(layout.bushes.size()):
		var p: Array = layout.bushes[i]
		object_at("Bush_%02d"%i,Vector2(p[0],p[1]),Rect2(0 if i%3==0 else 16,48,16,16))
	for i in range(layout.rocks.size()):
		var p: Array = layout.rocks[i]
		object_at("Rock_%02d"%i,Vector2(p[0],p[1]),Rect2(80,64,16,16),Vector2(11,7))
	for i in range(layout.flower_patches.size()):
		var p: Array = layout.flower_patches[i]
		var offset_list := [Vector2.ZERO,Vector2(1,0),Vector2(0,1),Vector2(2,1),Vector2(-1,2)]
		for j in range(offset_list.size()):
			var cell: Vector2 = Vector2(p[0],p[1])+offset_list[j]
			if not pond.has(Vector2i(cell)) and not route.has(Vector2i(cell)):
				object_at("Flower_%02d_%d"%[i,j],cell,Rect2(p[2]*16,48,16,16))
	for i in range(layout.mushrooms.size()):
		var p: Array = layout.mushrooms[i]
		object_at("Mushroom_%02d"%i,Vector2(p[0],p[1]),Rect2((5+i%3)*16,0,16,16))
	for i in range(layout.logs.size()):
		var p: Array = layout.logs[i]
		object_at("Log_%02d"%i,Vector2(p[0],p[1]),Rect2(0,64,32,16),Vector2(22,7))
	for i in range(layout.stumps.size()):
		var p: Array = layout.stumps[i]
		object_at("Stump_%02d"%i,Vector2(p[0],p[1]),Rect2(64,32,16,16),Vector2(9,6))
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
	# Garden has an open north entrance and generous walking space around it.
	var garden: Array = layout.garden
	var west: int = garden[0]-1
	var east: int = garden[2]+1
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
