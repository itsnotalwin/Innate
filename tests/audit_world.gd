extends SceneTree
## Inspect saved paths and scene objects, independently of the generation rules.

func _initialize() -> void:
	call_deferred("audit")

func audit() -> void:
	var world: Node2D = load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	var paths: TileMapLayer = world.get_node("Paths")
	var water: TileMapLayer = world.get_node("Water")
	var cells := {}
	for cell in paths.get_used_cells(): cells[cell] = true
	var spawn_position: Vector2 = world.get_node("Nature/Player").position / 16.0
	var start_path_cell := Vector2i.ZERO
	var spawn_to_path_tiles := INF
	for cell in cells:
		var distance := Vector2(cell).distance_to(spawn_position)
		if distance < spawn_to_path_tiles:
			spawn_to_path_tiles = distance
			start_path_cell = cell
	var queue: Array[Vector2i] = [start_path_cell]
	var seen := {queue[0]:true}
	var path_distance := {queue[0]:0}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+offset
			if cells.has(next) and not seen.has(next):
				seen[next] = true
				path_distance[next] = int(path_distance[cell])+1
				queue.append(next)
	var failures: Array[String] = []
	var disconnected_cells: Array[Vector2i] = []
	var disconnected_bridge_cells: Array[Vector2i] = []
	for cell in cells:
		if not seen.has(cell):
			disconnected_cells.append(cell)
			if cell.x >= 130 and cell.x <= 149 and cell.y >= 73 and cell.y <= 83:
				disconnected_bridge_cells.append(cell)
	if not disconnected_cells.is_empty(): failures.append("Disconnected painted paths")
	for cell in cells:
		if water.get_cell_source_id(cell) != -1: failures.append("Path crosses water at "+str(cell))
	var counts := {}
	var shortcut_counts := {"Mushroom":0,"Orchard":0}
	for node in world.get_node("Nature").get_children():
		var node_name := String(node.name)
		if "Approach" in node_name:
			var area := node_name.split("Approach")[0]
			if area.is_empty(): area = "Mushroom" if node_name.begins_with("ApproachMushroom") else "Orchard"
			counts[area] = int(counts.get(area,0))+1
		if node_name.begins_with("MushroomShortcutApproach"): shortcut_counts["Mushroom"] += 1
		if node_name.begins_with("OrchardShortcutApproach"): shortcut_counts["Orchard"] += 1
		if node.has_node("Solid") and node_name != "Cottage" and not node_name.begins_with("Fence_"):
			var cell := Vector2i(floori(node.position.x/16),floori(node.position.y/16))
			if cells.has(cell): failures.append("Solid prop occupies path: "+node_name)
	var approach_counts := {}
	for area in ["Orchard","Mushroom","Meadow","Pond","Creek"]:
		approach_counts[area] = int(counts.get(area,0))
		if approach_counts[area] < 4: failures.append("Sparse roadside approach: "+area)
	for area in shortcut_counts:
		if int(shortcut_counts[area]) < 4: failures.append("Bare cottage shortcut: "+area)
	var route_anchors := {"Cottage":Vector2(72,43),"Mushroom":Vector2(36,30),"Pond":Vector2(93,27),"Creek":Vector2(129,75),"Orchard":Vector2(99,70),"Meadow":Vector2(54,78)}
	var walking_seconds := {}
	for name in route_anchors:
		var nearest_steps := 2147483647
		for cell in path_distance:
			if Vector2(cell).distance_to(route_anchors[name]) < 1.5:
				nearest_steps = mini(nearest_steps,int(path_distance[cell]))
		if nearest_steps < 2147483647:
			walking_seconds[name] = snappedf((float(nearest_steps)+spawn_to_path_tiles)/4.5,0.1)
		else:
			failures.append("No connected route to timed destination: "+name)
	var report := {"path_cells":cells.size(),"connected_path_cells":seen.size(),"disconnected_path_cells":disconnected_cells,"disconnected_bridge_cells":disconnected_bridge_cells,
		"approach_objects":approach_counts,"shortcut_approach_objects":shortcut_counts,"route_walk_seconds_from_spawn":walking_seconds,
		"route_walk_origin":"player spawn","spawn_to_nearest_path_tiles":snappedf(spawn_to_path_tiles,0.01),
		"nature_objects":world.get_node("Nature").get_child_count(),"failures":failures}
	var file := FileAccess.open("res://tests/evidence/world-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print(JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
