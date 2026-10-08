extends CharacterBody2D
## One controller shared by keyboard and the native touch joystick.
@export_range(20.0, 160.0) var walking_speed: float = 72.0
var touch_direction := Vector2.ZERO
var facing := "down"
@onready var sprite: AnimatedSprite2D = $Sprite

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if touch_direction.length_squared() > direction.length_squared():
		direction = touch_direction
	velocity = direction.limit_length(1.0) * walking_speed
	move_and_slide()
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0 else "left"
		else:
			facing = "down" if direction.y > 0 else "up"
	var animation := ("walk_" if get_real_velocity().length_squared() > 1.0 else "idle_") + facing
	if sprite.animation != animation:
		sprite.play(animation)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		touch_direction = Vector2.ZERO
		velocity = Vector2.ZERO
		for action in ["move_left", "move_right", "move_up", "move_down"]:
			Input.action_release(action)
