extends Node2D
## Adapt the native canvas to portrait phones and wider displays without bars.
const PORTRAIT_SIZE := Vector2i(216, 384)
const LANDSCAPE_SIZE := Vector2i(384, 216)
const WORLD_SIZE := Vector2(1536, 1152)
var _web_resize_callback: JavaScriptObject
var _resize_pending := false

@onready var player: CharacterBody2D = $World/Nature/Player
@onready var joystick: Control = $Interface/MobileControls
@onready var countdown: Control = $Interface/Countdown

func _ready() -> void:
	joystick.direction_changed.connect(_set_touch_direction)
	get_window().size_changed.connect(_queue_resize)
	if OS.has_feature("web"):
		_web_resize_callback = JavaScriptBridge.create_callback(func(_args: Array):
			_queue_resize())
		JavaScriptBridge.get_interface("window").addEventListener("resize", _web_resize_callback)
	_apply_layout()
	player.reset_physics_interpolation()
	# Hide the HTML loader only once the actual game has drawn its first frame.
	if OS.has_feature("web"):
		await RenderingServer.frame_post_draw
		JavaScriptBridge.eval("window.innateReady()")

func _set_touch_direction(direction: Vector2) -> void:
	player.touch_direction = direction

func _queue_resize() -> void:
	if _resize_pending:
		return
	_resize_pending = true
	call_deferred("_apply_layout")

func _apply_layout() -> void:
	_resize_pending = false
	joystick.release_touch()
	var window := get_window()
	var screen := Vector2(window.size)
	if screen.x <= 0 or screen.y <= 0:
		return
	var base := PORTRAIT_SIZE if screen.y >= screen.x else LANDSCAPE_SIZE
	# Expanded logical view must remain smaller than the map, even on ultrawide screens.
	var scale_factor := minf(screen.x / base.x, screen.y / base.y)
	scale_factor = maxf(scale_factor, maxf(screen.x / WORLD_SIZE.x, screen.y / WORLD_SIZE.y))
	var logical_size := Vector2i(floori(screen.x / scale_factor), floori(screen.y / scale_factor))
	if window.content_scale_size != logical_size:
		window.content_scale_size = logical_size
	var camera: Camera2D = player.get_node("Camera")
	camera.reset_smoothing()
	# CSS safe-area values keep the joystick above phone home indicators/notches.
	if OS.has_feature("web"):
		var safe_area: Array = JSON.parse_string(str(JavaScriptBridge.eval("JSON.stringify(window.innateSafeArea())")))
		joystick.position = Vector2(14 + float(safe_area[0]) / scale_factor,
			logical_size.y - 78 - float(safe_area[1]) / scale_factor)
		countdown.position = Vector2(logical_size.x - countdown.size.x - 14 - float(safe_area[3]) / scale_factor,
			14 + float(safe_area[2]) / scale_factor)
	else:
		countdown.position = Vector2(logical_size.x - countdown.size.x - 14, 14)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		joystick.release_touch()

func _exit_tree() -> void:
	if _web_resize_callback != null:
		JavaScriptBridge.get_interface("window").removeEventListener("resize", _web_resize_callback)
