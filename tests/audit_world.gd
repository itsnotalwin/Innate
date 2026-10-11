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
	var queue: Array[Vector2i] = [paths.get_used_cells()[0]]
	var seen := {queue[0]:true}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+offset
			if cells.has(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	var failures: Array[String] = []
	if seen.size() != cells.size(): failures.append("Disconnected painted paths")
	for cell in cells:
		if water.get_cell_source_id(cell) != -1: failures.append("Path crosses water at "+str(cell))
	var counts := {}
	for node in world.get_node("Nature").get_children():
		var node_name := String(node.name)
		if "Approach" in node_name:
			var area := node_name.split("Approach")[0]
			if area.is_empty(): area = "Mushroom" if node_name.begins_with("ApproachMushroom") else "Orchard"
			counts[area] = int(counts.get(area,0))+1
		if node.has_node("Solid") and node_name != "Cottage" and not node_name.begins_with("Fence_"):
			var cell := Vector2i(floori(node.position.x/16),floori(node.position.y/16))
			if cells.has(cell): failures.append("Solid prop occupies path: "+node_name)
	var tile_counts := {}
	for area in ["Orchard","Mushroom","Meadow","Pond","Creek"]:
		var suffix := "Blooms" if area == "Orchard" else "Plants"
		var plants: TileMapLayer = world.get_node(area+"Approach"+suffix)
		tile_counts[area] = plants.get_used_cells().size()
		if plants.get_used_cells().is_empty(): failures.append("Empty approach: "+area)
	var report := {"path_cells":cells.size(),"connected_path_cells":seen.size(),
		"approach_objects":counts,"approach_plant_tiles":tile_counts,
		"nature_objects":world.get_node("Nature").get_child_count(),"failures":failures}
	var file := FileAccess.open("res://tests/evidence/world-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print(JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
