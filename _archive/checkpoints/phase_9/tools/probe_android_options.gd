extends SceneTree
func _init() -> void:
	call_deferred("probe")

func probe() -> void:
	var platform:=EditorExportPlatformAndroid.new()
	var preset:=platform.create_preset()
	var report: PackedStringArray=[]
	for property in preset.get_property_list():
		var key: String=property.name
		if key.contains("splash") or key.contains("icon") or key.contains("permissions/") or key.contains("gradle") or key.contains("architecture") or key.contains("orientation"):
			report.append(JSON.stringify(property)+" value="+str(preset.get(key)))
	var file:=FileAccess.open("res://build/evidence/android-options.txt",FileAccess.WRITE)
	file.store_string("\n".join(report))
	file.close()
	print("Android options: ",report.size()," recorded from Godot-created preset")
	quit()
