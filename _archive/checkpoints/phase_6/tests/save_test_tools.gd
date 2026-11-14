class_name SaveTestTools
extends RefCounted

const Service = preload("res://scripts/save_service.gd")

static func service(label: String):
	var directory := "user://test_%s_%d" % [label,Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var instance = Service.new()
	instance.save_path=directory+"/lumiblock_save.json"
	return instance

static func write(path: String, value: String) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(value)
	file.close()
