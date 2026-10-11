extends SceneTree
## Reduce the edited master to native sprite cells and the existing pack palette.

func _initialize() -> void:
	var source := Image.load_from_file("res://art/picnic_props_master.png")
	var reference := Image.load_from_file("res://assets/sprout_lands/nature.png")
	if source == null or reference == null:
		push_error("Missing picnic master or native palette reference")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	reference.convert(Image.FORMAT_RGBA8)
	var palette: Array[Color] = []
	for y in range(reference.get_height()):
		for x in range(reference.get_width()):
			var color := reference.get_pixel(x,y)
			if color.a > 0.99 and not palette.has(color): palette.append(color)
	var atlas := Image.create(112,32,false,Image.FORMAT_RGBA8)
	# Explicit source bounds isolate each generated sprite; no edge bleeds.
	var sprites := [
		[Rect2(0.018,0.14,0.42,0.70),Vector2i(48,32),Vector2i(0,0)],
		[Rect2(0.44,0.15,0.14,0.43),Vector2i(16,16),Vector2i(48,0)],
		[Rect2(0.59,0.24,0.115,0.34),Vector2i(16,16),Vector2i(64,0)],
		[Rect2(0.715,0.22,0.14,0.36),Vector2i(16,16),Vector2i(80,0)],
		[Rect2(0.855,0.22,0.145,0.36),Vector2i(16,16),Vector2i(96,0)],
	]
	for entry in sprites:
		var bounds: Rect2 = entry[0]
		var dimensions := Vector2(source.get_width(),source.get_height())
		var region := Rect2i(Vector2i(bounds.position*dimensions),Vector2i(bounds.size*dimensions))
		var sprite := source.get_region(region)
		var size: Vector2i = entry[1]
		sprite.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
		for y in range(size.y):
			for x in range(size.x):
				var pixel := sprite.get_pixel(x,y)
				# Discard translucent and bright key-color remnants at cutout edges.
				if pixel.a < 0.65 or (pixel.r > 0.9 and pixel.g < 0.2) or (pixel.r > 0.9 and pixel.g > 0.85 and pixel.b < 0.2):
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
		atlas.blit_rect(sprite,Rect2i(Vector2i.ZERO,size),entry[2])
	var result := atlas.save_png("res://assets/sprout_lands/picnic_grove.png")
	print("Prepared 112x32 picnic atlas using ",palette.size()," native palette colors")
	quit(0 if result == OK else 1)
