extends Control
## Compact date countdown for the requested event, using the player's local clock.
const TARGET_DATE := {"year": 2027, "month": 5, "day": 26, "hour": 0, "minute": 0, "second": 0}
const PANEL_SIZE := Vector2(104, 32)

var target_unix := 0
var timer_label: Label
var displayed_second := -1

func _ready() -> void:
	size = PANEL_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_unix = int(Time.get_unix_time_from_datetime_dict(TARGET_DATE))
	_build_panel()
	_update_countdown()

func _process(_delta: float) -> void:
	var now := int(Time.get_unix_time_from_system())
	if now != displayed_second:
		_update_countdown(now)

func _build_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "CountdownPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#173b3d")
	style.bg_color.a = 0.92
	style.border_color = Color("#8ebd98")
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "CountdownMargins"
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.name = "CountdownContent"
	stack.add_theme_constant_override("separation", 0)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)

	var date_label := Label.new()
	date_label.name = "DateLabel"
	date_label.text = "MAY 26, 2027"
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_label.add_theme_font_size_override("font_size", 6)
	date_label.add_theme_color_override("font_color", Color("#c9daa9"))
	date_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(date_label)

	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 9)
	timer_label.add_theme_color_override("font_color", Color("#fff0bd"))
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(timer_label)

func _update_countdown(now := int(Time.get_unix_time_from_system())) -> void:
	displayed_second = now
	var remaining := maxi(0, target_unix - now)
	var days := remaining / 86400
	var hours := (remaining % 86400) / 3600
	var minutes := (remaining % 3600) / 60
	var seconds := remaining % 60
	timer_label.text = "%03dd %02d:%02d:%02d" % [days, hours, minutes, seconds]
