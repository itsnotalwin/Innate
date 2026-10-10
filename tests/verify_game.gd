extends SceneTree
## Small integration test: exercise real controller and physics in the saved world.
var main: Node2D
var player: CharacterBody2D
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("PASS ",label)
	else:
		failures.append(label)
		push_error("FAIL "+label)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func release() -> void:
	for action in ["move_left","move_right","move_up","move_down"]: Input.action_release(action)
	player.touch_direction = Vector2.ZERO

func move_from(start: Vector2, actions: Array[String], count: int) -> Vector2:
	release()
	player.position = start
	player.reset_physics_interpolation()
	player.velocity = Vector2.ZERO
	await frames(2)
	for action in actions: Input.action_press(action)
	await frames(count)
	var end := player.position
	release()
	await frames(2)
	return end

func verify() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(4)
	player = main.get_node("World/Nature/Player")
	check(player is CharacterBody2D,"one native controllable player initialized")
	check(main.get_node("World/Nature").y_sort_enabled,"player and nature share Y sorting")
	check(main.get_node("World/Ground").get_used_cells().size()>6500,"native saved expanded 96x72 ground cells loaded")
	var countdown: Control=main.get_node("Interface/Countdown")
	check(countdown.get_node("CountdownPanel/CountdownMargins/CountdownContent/DateLabel").text=="MAY 26, 2027","countdown shows the requested target date")
	check(countdown.get_node("CountdownPanel/CountdownMargins/CountdownContent/TimerLabel").text.length()==13 and countdown.target_unix>Time.get_unix_time_from_system(),"countdown is live, nonnegative, and counts to a future instant")
	check(countdown.position.x>=0 and countdown.position.y==14,"countdown sits inside the top-right screen corner")
	var start := Vector2(640,656)
	var right := await move_from(start,["move_right"],30)
	check(absf(right.x-start.x-36)<1.3,"cardinal speed: 72 px/s for 30 physics ticks")
	var diagonal := await move_from(start,["move_right","move_down"],30)
	check(absf(diagonal.distance_to(start)-right.distance_to(start))<1.3,"diagonal speed equals cardinal speed")
	for data in [["move_up","up"],["move_down","down"],["move_left","left"],["move_right","right"]]:
		player.position=start
		Input.action_press(data[0])
		await frames(3)
		check(player.get_node("Sprite").animation=="walk_"+data[1],"walking animation "+data[1])
		release()
		await frames(2)
		check(player.get_node("Sprite").animation=="idle_"+data[1],"idle preserves facing "+data[1])
	var tree := await move_from(Vector2(776,638),["move_down"],60)
	check(tree.y<657 and tree.y>652,"tree trunk blocks feet, not whole canopy")
	var pond := await move_from(Vector2(1148,552),["move_left"],60)
	check(pond.x>1123 and pond.x<1126,"pond prevents walking across open water")
	var house := await move_from(Vector2(512,672),["move_up"],60)
	check(house.y>647 and house.y<650,"cottage footprint blocks entry")
	var fence := await move_from(Vector2(520,872),["move_up"],60)
	check(fence.y>850 and fence.y<853,"garden fence blocks feet")
	for data in [[Vector2(768,20),"move_up",0],[Vector2(768,1132),"move_down",1],[Vector2(20,576),"move_left",2],[Vector2(1516,576),"move_right",3]]:
		var end := await move_from(data[0],[data[1]],60)
		check(end.x>=3.9 and end.x<=1532.1 and end.y>=3.9 and end.y<=1148.1,"world boundary "+str(data[2]))
	var camera: Camera2D=player.get_node("Camera")
	for position in [Vector2(768,576),Vector2(768,4),Vector2(768,1148),Vector2(4,576),Vector2(1532,576)]:
		player.position=position
		camera.reset_smoothing()
		await frames(2)
		var center:=camera.get_screen_center_position()
		var half_view := Vector2(root.content_scale_size) / 2.0
		check(center.x>=half_view.x-0.1 and center.x<=1536.1-half_view.x and center.y>=half_view.y-0.1 and center.y<=1152.1-half_view.y,"camera stays inside map at "+str(position))
	var joystick: Control=main.get_node("Interface/MobileControls")
	joystick.visible=true
	player.position=start
	var touch:=InputEventScreenTouch.new()
	touch.index=0;touch.pressed=true
	touch.position=joystick.global_position+Vector2(56,32)
	joystick._input(touch)
	await frames(30)
	check(player.position.x>start.x+34,"native touch uses same walking controller")
	var unrelated:=InputEventScreenTouch.new()
	unrelated.index=1;unrelated.pressed=false;unrelated.position=Vector2.ZERO
	joystick._input(unrelated)
	check(joystick.finger==0,"second finger release does not stop active finger")
	touch.pressed=false;touch.position=Vector2(300,10)
	joystick._input(touch)
	await frames(2)
	var stopped:=player.position
	await frames(10)
	check(player.position.is_equal_approx(stopped),"release outside joystick stops movement")
	touch.pressed=true;touch.position=joystick.global_position+Vector2(56,32)
	joystick._input(touch)
	touch.canceled=true;touch.pressed=false
	joystick._input(touch)
	check(player.touch_direction==Vector2.ZERO and joystick.finger==-1,"touch cancellation clears movement")
	touch.canceled=false;touch.pressed=true
	joystick._input(touch)
	joystick._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(player.touch_direction==Vector2.ZERO,"focus loss clears touch")
	joystick._input(touch)
	joystick.release_touch()
	check(player.touch_direction==Vector2.ZERO,"resize release clears touch")
	release()
	player.position = Vector2(640,656)
	player.reset_physics_interpolation()
	await frames(2)
	camera.reset_smoothing()
	await frames(2)
	var previous_center := camera.get_screen_center_position()
	var largest_step := 0.0
	var fractional_steps := 0
	Input.action_press("move_right")
	for i in range(30):
		await frames(1)
		var center := camera.get_screen_center_position()
		largest_step = maxf(largest_step,center.distance_to(previous_center))
		if absf(center.x-roundf(center.x)) > 0.01: fractional_steps += 1
		previous_center = center
	release()
	check(largest_step < 2.0,"camera follows without large per-tick jumps")
	check(fractional_steps > 15,"camera preserves subpixel positions instead of whole-pixel snapping")
	check(main.get_node("Interface").get_child_count()==2,"gameplay interface contains touch controls and the requested countdown")
	root.size = Vector2i(390,844)
	main._apply_layout()
	await frames(2)
	check(root.content_scale_size.x < root.content_scale_size.y,"phone layout fills a portrait screen")
	check(absf(countdown.position.x-(root.content_scale_size.x-countdown.size.x-14))<0.1 and countdown.position.y==14,"countdown remains at the top-right in portrait layout")
	root.size = Vector2i(3840,720)
	main._apply_layout()
	await frames(2)
	check(root.content_scale_size.x <= 1536 and root.content_scale_size.y <= 1152,"ultrawide layout never reveals outside the world")
	var report={"checks":checks,"failures":failures,"godot":Engine.get_version_info().string}
	var file:=FileAccess.open("res://tests/evidence/native-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("RESULT ",checks-failures.size(),"/",checks," passed")
	quit(0 if failures.is_empty() else 1)
