extends Control
## Invisible full-screen touch surface; drag from anywhere to steer.
signal direction_changed(direction: Vector2)
const RADIUS := 24.0
var finger := -1
var touch_origin := Vector2.ZERO
var direction := Vector2.ZERO

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var local: Vector2
	if event is InputEventScreenTouch:
		local = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed and not event.canceled and finger == -1 and Rect2(Vector2.ZERO, size).has_point(local):
			finger = event.index
			touch_origin = local
			_update_direction(local)
			get_viewport().set_input_as_handled()
		elif event.index == finger and (not event.pressed or event.canceled):
			release_touch()
	elif event is InputEventScreenDrag and event.index == finger:
		local = get_global_transform_with_canvas().affine_inverse() * event.position
		_update_direction(local)
		get_viewport().set_input_as_handled()

func _update_direction(local: Vector2) -> void:
	direction = ((local - touch_origin) / RADIUS).limit_length(1.0)
	if direction.length() < 0.16:
		direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func release_touch() -> void:
	finger = -1
	touch_origin = Vector2.ZERO
	direction = Vector2.ZERO
	direction_changed.emit(direction)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		release_touch()
