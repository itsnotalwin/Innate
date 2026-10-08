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
	check(main.get_node("World/Ground").get_used_cells().size()>2900,"native saved 64x48 ground cells loaded")
	var start := Vector2(384,464)
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
	var tree := await move_from(Vector2(520,446),["move_down"],60)
	check(tree.y<465 and tree.y>460,"tree trunk blocks feet, not whole canopy")
	var pond := await move_from(Vector2(892,360),["move_left"],60)
	check(pond.x>867 and pond.x<870,"pond prevents walking across open water")
	var house := await move_from(Vector2(256,480),["move_up"],60)
	check(house.y>455 and house.y<458,"cottage footprint blocks entry")
	var fence := await move_from(Vector2(264,680),["move_up"],60)
	check(fence.y>658 and fence.y<661,"garden fence blocks feet")
	for data in [[Vector2(520,20),"move_up",0],[Vector2(520,748),"move_down",1],[Vector2(20,400),"move_left",2],[Vector2(1004,400),"move_right",3]]:
		var end := await move_from(data[0],[data[1]],60)
		check(end.x>=3.9 and end.x<=1020.1 and end.y>=3.9 and end.y<=764.1,"world boundary "+str(data[2]))
	var camera: Camera2D=player.get_node("Camera")
	for position in [Vector2(520,384),Vector2(520,4),Vector2(520,764),Vector2(4,400),Vector2(1020,400)]:
		player.position=position
		camera.reset_smoothing()
		await frames(2)
		var center:=camera.get_screen_center_position()
		check(center.x>=191.9 and center.x<=832.1 and center.y>=107.9 and center.y<=660.1,"camera stays inside map at "+str(position))
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
	joystick._release()
	check(player.touch_direction==Vector2.ZERO,"resize release clears touch")
	var report={"checks":checks,"failures":failures,"godot":Engine.get_version_info().string}
	var file:=FileAccess.open("res://tests/evidence/native-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("RESULT ",checks-failures.size(),"/",checks," passed")
	quit(0 if failures.is_empty() else 1)
