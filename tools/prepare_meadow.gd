extends SceneTree
## Convert the edited sprite master into a compact, crisp native 16px atlas.
const FLOWER_ROW_BOUNDS := [0, 375, 625, 940, 1254]

func _initialize() -> void:
	var source := Image.load_from_file("res://art/meadow_flowers_master.png")
	if source == null:
		push_error("Missing edited meadow sprite master")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var palette_json: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/innate/environment_palette.json"))
	if not palette_json is Array or palette_json.is_empty():
		push_error("Missing shared environment palette; run tools/prepare_environment_atlases.py first")
		quit(1)
		return
	var palette: Array[Color] = []
	for color_hex in palette_json:
		palette.append(Color(String(color_hex)))
	var atlas := Image.create(64,64,false,Image.FORMAT_RGBA8)
	for row in range(4):
		for column in range(4):
			var origin := Vector2i(roundi(column*source.get_width()/4.0),FLOWER_ROW_BOUNDS[row])
			var end := Vector2i(roundi((column+1)*source.get_width()/4.0),FLOWER_ROW_BOUNDS[row+1])
			var sprite := source.get_region(Rect2i(origin,end-origin))
			sprite.resize(16,16,Image.INTERPOLATE_NEAREST)
			for y in range(16):
				for x in range(16):
					var pixel := sprite.get_pixel(x,y)
					if pixel.a < 0.9:
						sprite.set_pixel(x,y,Color.TRANSPARENT)
						continue
					var best := palette[0]
					var distance := INF
					for color in palette:
						var delta := Vector3(pixel.r-color.r,pixel.g-color.g,pixel.b-color.b)
						if delta.length_squared() < distance:
							distance = delta.length_squared()
							best = color
					sprite.set_pixel(x,y,best)
			atlas.blit_rect(sprite,Rect2i(0,0,16,16),Vector2i(column*16,row*16))
	DirAccess.make_dir_recursive_absolute("res://assets/wildflowers/meadow")
	var result := atlas.save_png("res://assets/wildflowers/meadow/flowers.png")
	if result != OK:
		push_error("Could not save meadow atlas")
		quit(1)
		return
	print("Prepared 16 native meadow sprites with the shared environment palette.")
	quit()
