extends SceneTree

func _init() -> void:
	var report := PackedStringArray()
	for cls in ["Logger", "OS"]:
		if not ClassDB.class_exists(cls): continue
		for method in ClassDB.class_get_method_list(cls):
			if cls == "Logger" or "logger" in str(method.name): report.append("LOGGER " + cls + " " + JSON.stringify(method))
	for pair in [["Input", "vibrate_handheld"], ["DisplayServer", "get_display_safe_area"], ["Image", "load_svg_from_string"], ["FontFile", "has_char"], ["Engine", "get_license_text"], ["Engine", "get_copyright_info"], ["HashingContext", "start"], ["FileAccess", "get_sha256"]]:
		report.append("%s.%s exists=%s" % [pair[0], pair[1], ClassDB.class_has_method(pair[0], pair[1])])
		for method in ClassDB.class_get_method_list(pair[0]):
			if method.name == pair[1]: report.append(JSON.stringify(method))
	for key in ["application/config/quit_on_go_back", "display/window/stretch/aspect", "input_devices/pointing/emulate_touch_from_mouse", "input_devices/pointing/emulate_mouse_from_touch", "internationalization/locale/fallback", "audio/buses/default_bus_layout"]:
		report.append("%s exists=%s default=%s" % [key, ProjectSettings.has_setting(key), str(ProjectSettings.get_setting(key))])
	report.append("user directory: " + OS.get_user_data_dir())
	var file := FileAccess.open("res://build/evidence/api-probe.txt", FileAccess.WRITE)
	file.store_string("\n".join(report))
	file.close()
	print("\n".join(report))
	quit(0)
