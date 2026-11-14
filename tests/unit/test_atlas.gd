extends RefCounted

func run(t) -> void:
	var image:=Image.new()
	var error:=image.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/cubes/cube_atlas.png"))
	t.check_eq(error,OK,"atlas PNG loads")
	if error!=OK: return
	t.check_eq(image.get_size(),Vector2i(512,768),"atlas dimensions")
	var intermediate:=false
	for y in 128:
		for x in 128:
			var alpha:=image.get_pixel(x,y).a
			if alpha>0 and alpha<1: intermediate=true
	t.check(intermediate,"antialiased alpha edge exists")
	t.check_eq(image.get_pixel(0,0).a,0.0,"transparent atlas corner")
	t.check_eq(image.get_pixel(64,64).a,1.0,"opaque body center")
