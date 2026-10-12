extends Control
## Invisible full-screen touch surface; drag from anywhere to steer.
signal direction_changed(direction: Vector2)
signal pinch_zoomed(factor: float)
const RADIUS := 24.0
const DEADZONE := 0.16
var finger := -1
var touch_origin := Vector2.ZERO
var direction := Vector2.ZERO
var touch_points: Dictionary = {}
var touch_order: Array[int] = []
var pinch_fingers: Array[int] = []
var pinch_active := false
var previous_pinch_distance := 0.0

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var local: Vector2
	if event is InputEventScreenTouch:
		local = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed and not event.canceled:
			if not Rect2(Vector2.ZERO, size).has_point(local): return
			if touch_points.has(event.index):
				touch_points[event.index] = local
				get_viewport().set_input_as_handled()
				return
			touch_points[event.index] = local
			touch_order.append(event.index)
			if touch_order.size() >= 2:
				_begin_pinch()
				get_viewport().set_input_as_handled()
			elif finger == -1 and not pinch_active:
				finger = event.index
				touch_origin = local
				_update_direction(local)
				get_viewport().set_input_as_handled()
		elif not event.pressed or event.canceled:
			touch_points.erase(event.index)
			touch_order.erase(event.index)
			if event.index == finger:
				release_touch()
			if pinch_active and (not touch_points.has(pinch_fingers[0]) or not touch_points.has(pinch_fingers[1])):
				_end_pinch()
	elif event is InputEventScreenDrag and touch_points.has(event.index):
		local = get_global_transform_with_canvas().affine_inverse() * event.position
		touch_points[event.index] = local
		if pinch_active:
			_update_pinch()
		elif event.index == finger:
			_update_direction(local)
		get_viewport().set_input_as_handled()

func _begin_pinch() -> void:
	if pinch_active or touch_order.size() < 2: return
	pinch_fingers = [touch_order[touch_order.size()-2], touch_order[touch_order.size()-1]]
	pinch_active = true
	previous_pinch_distance = 0.0
	# A second finger takes over from movement so zooming never drifts the player.
	_stop_direction()
	_update_pinch()

func _update_pinch() -> void:
	if not pinch_active or not touch_points.has(pinch_fingers[0]) or not touch_points.has(pinch_fingers[1]): return
	var distance := Vector2(touch_points[pinch_fingers[0]]).distance_to(Vector2(touch_points[pinch_fingers[1]]))
	if previous_pinch_distance > 1.0 and distance > 1.0:
		var factor := distance / previous_pinch_distance
		if absf(factor - 1.0) > 0.002:
			pinch_zoomed.emit(factor)
	previous_pinch_distance = distance

func _end_pinch() -> void:
	pinch_active = false
	pinch_fingers.clear()
	previous_pinch_distance = 0.0

func _update_direction(local: Vector2) -> void:
	var offset := (local - touch_origin) / RADIUS
	var strength := clampf((offset.length() - DEADZONE) / (1.0 - DEADZONE), 0.0, 1.0)
	var next_direction := offset.normalized() * strength
	if not direction.is_equal_approx(next_direction):
		direction = next_direction
		direction_changed.emit(direction)

func release_touch() -> void:
	if finger != -1:
		touch_points.erase(finger)
		touch_order.erase(finger)
	_stop_direction()

func _stop_direction() -> void:
	finger = -1
	touch_origin = Vector2.ZERO
	direction = Vector2.ZERO
	direction_changed.emit(direction)

func cancel_all() -> void:
	release_touch()
	touch_points.clear()
	touch_order.clear()
	_end_pinch()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		cancel_all()
