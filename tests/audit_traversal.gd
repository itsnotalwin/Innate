extends SceneTree
## Actual feet-sized physics probes and swept edges, not just painted-path checks.
const OFFSETS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

func _initialize() -> void:
	call_deferred("audit")

func audit() -> void:
	var world: Node2D = load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	await process_frame
	var player: CharacterBody2D = world.get_node("Nature/Player")
	player.set_physics_process(false)
	var space := world.get_world_2d().direct_space_state
	var probe := PhysicsShapeQueryParameters2D.new()
	var feet := CircleShape2D.new()
	feet.radius = 4.1
	probe.shape = feet
	probe.collision_mask = 1
	var free := {}
	for y in range(104):
		for x in range(128):
			var cell := Vector2i(x,y)
			probe.transform = Transform2D(0, Vector2(cell)*16.0+Vector2(8,8))
			if space.intersect_shape(probe,1).is_empty(): free[cell] = true
	var spawn := Vector2i(player.position / 16.0)
	var queue: Array[Vector2i] = [spawn]
	var reached := {spawn:true}
	var parent_cells := {}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for offset in OFFSETS:
			var next: Vector2i = cell + offset
			if not free.has(next) or reached.has(next): continue
			probe.transform = Transform2D(0,Vector2(cell)*16.0+Vector2(8,8))
			probe.motion = Vector2(offset)*16.0
			if space.cast_motion(probe)[0] < 1.0: continue
			reached[next] = true
			parent_cells[next] = cell
			queue.append(next)
	var destinations := {"Cottage":Vector2i(57,55),"Mushroom":Vector2i(27,35),"Meadow":Vector2i(24,80),"Pond":Vector2i(75,33),"Creek":Vector2i(107,67),"Orchard":Vector2i(62,23)}
	var failures: Array[String] = []
	var destinations_checked := {}
	var swept_steps := 0
	for name in destinations:
		var accessible := reached.has(destinations[name])
		destinations_checked[name] = accessible
		if not accessible: failures.append("Destination unreachable with player feet: " + name)
		if accessible:
			var journey: Array[Vector2i] = [destinations[name]]
			while journey.back() != spawn: journey.append(parent_cells[journey.back()])
			journey.reverse()
			player.position = Vector2(spawn)*16.0+Vector2(8,8)
			for index in range(1,journey.size()):
				var target := Vector2(journey[index])*16.0+Vector2(8,8)
				if player.move_and_collide(target-player.position) != null:
					failures.append("Real player collision en route to " + name)
					break
				swept_steps += 1
			journey.reverse()
			for index in range(1,journey.size()):
				var target := Vector2(journey[index])*16.0+Vector2(8,8)
				if player.move_and_collide(target-player.position) != null:
					failures.append("Real player collision returning from " + name)
					break
				swept_steps += 1
	var blocked_paths: Array[Vector2i] = []
	var isolated_paths: Array[Vector2i] = []
	for cell in world.get_node("Paths").get_used_cells():
		if not free.has(cell):
			blocked_paths.append(cell)
			probe.motion = Vector2.ZERO
			probe.transform = Transform2D(0,Vector2(cell)*16.0+Vector2(8,8))
			for hit in space.intersect_shape(probe):
				var obstacle := String(hit.collider.get_parent().name)
				if obstacle != "Cottage" and not obstacle.begins_with("Fence_"):
					failures.append("Unexpected obstacle intrudes on path: " + obstacle + " at " + str(cell))
		elif not reached.has(cell): isolated_paths.append(cell)
	if not isolated_paths.is_empty(): failures.append("Unreachable walkable path cells: " + str(isolated_paths))
	var report := {"probe_radius":feet.radius,"free_cells":free.size(),"reachable_cells":reached.size(),"destinations":destinations_checked,"real_player_swept_steps":swept_steps,"blocked_path_cells":blocked_paths,"isolated_path_cells":isolated_paths,"failures":failures}
	var file := FileAccess.open("res://tests/evidence/traversal-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print(JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
