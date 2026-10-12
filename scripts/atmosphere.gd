extends Node2D
var _mounted := false
## Static, world-space afternoon lighting: no lights, particles or frame updates.
func _ready() -> void:
	_mount.call_deferred()

func _mount() -> void:
	var world := get_parent().get_node("World")
	reparent(world)
	world.move_child(self, world.get_node("Nature").get_index())
	_mounted = true
	queue_redraw()

func _draw() -> void:
	if not _mounted:
		return
	var nature := get_parent().get_node("Nature")
	for object in nature.get_children():
		var artwork := object.get_node_or_null("Artwork") as Sprite2D
		if artwork == null or artwork.region_rect.size.y < 32:
			continue
		if not ("Tree" in object.name or "tree" in object.name):
			continue
		# Layered elongated shadows fall southeast, anchored at each trunk.
		var radius := artwork.region_rect.size.x * artwork.scale.x * 0.23
		for shell in range(3, 0, -1):
			var polygon := PackedVector2Array()
			for i in range(20):
				var angle := TAU * i / 20.0
				polygon.append(object.position + Vector2(8, 5) + Vector2(cos(angle) * (radius + shell * 1.5), sin(angle) * (radius * 0.36 + shell)))
			draw_colored_polygon(polygon, Color(0.12, 0.20, 0.25, 0.038))
