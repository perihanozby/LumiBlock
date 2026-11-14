extends RefCounted

class FailingRename extends "res://scripts/save_service.gd":
	var fail_rename := false
	func rename_file(source: String,destination: String) -> Error:
		if fail_rename: return ERR_CANT_CREATE
		return super.rename_file(source,destination)

func run(t) -> void:
	var helper = SaveTestTools.service("atomic")
	var service := FailingRename.new()
	service.save_path=helper.save_path
	helper.free()
	var data := SaveSchema.defaults()
	t.check(service.save_game(data,true),"atomic fixture main")
	var original := FileAccess.get_file_as_string(service.save_path)
	var failed := [0]
	service.save_failed.connect(func(): failed[0]+=1)
	service.fail_rename=true
	data.records.best_classic=42
	t.check(not service.save_game(data,true),"injected rename fails")
	t.check_eq(failed[0],1,"save_failed emitted")
	t.check_eq(FileAccess.get_file_as_string(service.save_path),original,"old bytes restored after rename failure")
	t.check_eq(service.load_game().records.best_classic,0,"old profile readable")
	service.fail_rename=false
	t.check(service.save_game(data,true),"retry succeeds")
	service.free()
