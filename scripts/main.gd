extends Node2D
var _web_resize_callback: JavaScriptObject

func _ready() -> void:
	$Interface/MobileControls.direction_changed.connect(func(direction: Vector2):
		$World/Nature/Player.touch_direction = direction)
	_update_orientation()
	get_viewport().size_changed.connect(_on_resize)
	if OS.has_feature("web"):
		_web_resize_callback = JavaScriptBridge.create_callback(func(_args: Array):
			call_deferred("_on_resize"))
		JavaScriptBridge.get_interface("window").addEventListener("resize", _web_resize_callback)

func _on_resize() -> void:
	$Interface/MobileControls._release()
	_update_orientation()

func _update_orientation() -> void:
	var screen := DisplayServer.window_get_size()
	var portrait := screen.y > screen.x
	if OS.has_feature("web"):
		portrait = bool(JavaScriptBridge.eval("window.innerHeight > window.innerWidth"))
	$Interface/RotateHint.visible = portrait

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		$Interface/MobileControls._release()

func _exit_tree() -> void:
	if _web_resize_callback != null:
		JavaScriptBridge.get_interface("window").removeEventListener("resize", _web_resize_callback)
