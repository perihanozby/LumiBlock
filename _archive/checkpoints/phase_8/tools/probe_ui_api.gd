extends SceneTree

func _init() -> void:
	var lines := PackedStringArray()
	for pair in [["Control","set_anchors_and_offsets_preset"],["Control","get_global_rect"],["Theme","set_type_variation"],["Theme","set_font_size"],["Font","set_fallbacks"],["StyleBoxFlat","set_corner_radius_all"],["Image","save_png"],["Translation","add_message"],["DisplayServer","get_display_cutouts"],["Tween","kill"]]:
		var found := ClassDB.class_has_method(pair[0],pair[1])
		lines.append("%s.%s=%s" % [pair[0],pair[1],found])
		for method in ClassDB.class_get_method_list(pair[0]):
			if method.name==pair[1]: lines.append(JSON.stringify(method))
	var control := Control.new()
	control.layout_direction=Control.LAYOUT_DIRECTION_RTL
	lines.append("Control.layout_direction RTL=%d" % control.layout_direction)
	control.free()
	var image := Image.create(2,2,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	lines.append("Image.create/fill size="+str(image.get_size()))
	var file := FileAccess.open("res://build/evidence/ui-api-probe.txt",FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()
	print("\n".join(lines))
	quit()
