extends SceneTree

func _init() -> void:
	var golden:="res://tests/screenshots/golden/final/"
	var actual:="res://tests/screenshots/actual/final/"
	var failures:=0
	var count:=0
	var lines: PackedStringArray=[]
	for filename in DirAccess.get_files_at(golden):
		if not filename.ends_with(".png"): continue
		var reference:=Image.new()
		var current:=Image.new()
		if reference.load_png_from_buffer(FileAccess.get_file_as_bytes(golden+filename))!=OK or current.load_png_from_buffer(FileAccess.get_file_as_bytes(actual+filename))!=OK:
			failures+=1
			continue
		if reference.get_size()!=current.get_size():
			failures+=1
			continue
		reference.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var a:=reference.get_data()
		var b:=current.get_data()
		var different:=0
		for offset in range(0,a.size(),4):
			for channel in 4:
				if absi(a[offset+channel]-b[offset+channel])>3:
					different+=1
					break
		var fraction:=float(different)/(reference.get_width()*reference.get_height())
		if fraction>0.005: failures+=1
		count+=1
		lines.append("%s %.6f%%" % [filename,fraction*100])
	if count==0: failures+=1
	var file:=FileAccess.open("res://build/evidence/screenshot-regression.txt",FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.store_line("\nScreenshot regression: %d images, %d failures; channel tolerance 3, differing-pixel limit 0.5%%" % [count,failures])
	file.close()
	print("Screenshot regression: %d images, %d failures" % [count,failures])
	quit(1 if failures else 0)
