extends SceneTree
## Convert the edited sprite master into a compact, crisp native 16px atlas.
const PALETTE := [
	Color("5b7465"), Color("7d9870"), Color("a6bd7d"), Color("c5d496"),
	Color("c9956c"), Color("e4ae76"), Color("efc18c"),
	Color("d3ba7e"), Color("e7d69c"), Color("f6e7b7"),
	Color("b38196"), Color("cd9caf"), Color("e5b9c4"),
	Color("8297ad"), Color("a2b4c4"), Color("c4d0d4"), Color("f4dca0"),
]

func _initialize() -> void:
	var source := Image.load_from_file("res://art/meadow_flowers_master.png")
	if source == null:
		push_error("Missing edited meadow sprite master")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var atlas := Image.create(64,64,false,Image.FORMAT_RGBA8)
	for row in range(4):
		for column in range(4):
			var origin := Vector2i(roundi(column*source.get_width()/4.0),roundi(row*source.get_height()/4.0))
			var end := Vector2i(roundi((column+1)*source.get_width()/4.0),roundi((row+1)*source.get_height()/4.0))
			var sprite := source.get_region(Rect2i(origin,end-origin))
			sprite.resize(16,16,Image.INTERPOLATE_NEAREST)
			for y in range(16):
				for x in range(16):
					var pixel := sprite.get_pixel(x,y)
					if pixel.a < 0.5:
						sprite.set_pixel(x,y,Color.TRANSPARENT)
						continue
					var best := PALETTE[0]
					var distance := INF
					for color in PALETTE:
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
	print("Prepared 16 meadow sprites at native resolution with a shared 17-color palette.")
	quit()
