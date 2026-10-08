extends Control
## Tracks one touch ID; releases outside the control and on focus/resize changes.
signal direction_changed(direction: Vector2)
const CENTER := Vector2(32, 32)
const RADIUS := 24.0
var finger := -1
var direction := Vector2.ZERO

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	get_viewport().size_changed.connect(_release)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed and not event.canceled and finger == -1 and Rect2(Vector2.ZERO, size).has_point(local):
			finger = event.index
			_update_direction(local)
			get_viewport().set_input_as_handled()
		elif event.index == finger and (not event.pressed or event.canceled):
			_release()
	elif event is InputEventScreenDrag and event.index == finger:
		_update_direction(get_global_transform_with_canvas().affine_inverse() * event.position)
		get_viewport().set_input_as_handled()

func _update_direction(local: Vector2) -> void:
	direction = ((local - CENTER) / RADIUS).limit_length(1.0)
	if direction.length() < 0.16:
		direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func _release() -> void:
	finger = -1
	direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_release()

func _draw() -> void:
	draw_circle(CENTER, 29, Color(0.2, 0.3, 0.25, 0.28))
	draw_arc(CENTER, 28, 0, TAU, 48, Color(1, 0.97, 0.8, 0.6), 1.0)
	for axis in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		draw_circle(CENTER + axis * 21, 1.5, Color(1, 0.97, 0.8, 0.65))
	draw_circle(CENTER + direction * 18, 10, Color(1, 0.97, 0.8, 0.62))
