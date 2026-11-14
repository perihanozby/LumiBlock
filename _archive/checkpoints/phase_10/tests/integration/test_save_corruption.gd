extends RefCounted

const SaveTools = preload("res://tests/save_test_tools.gd")

func run(t) -> void:
	for corrupt in ["{","garbage","[]",'{"schema":2,"data":{},"checksum":"wrong"}', '{"schema":2,"data":42}']:
		var service = SaveTools.service("corrupt")
		var data := SaveSchema.defaults()
		data.records.best_classic=123
		service.save_game(data,true)
		data.records.best_classic=456
		service.save_game(data,true)
		SaveTools.write(service.save_path,corrupt)
		t.check_eq(service.load_game().records.best_classic,123,"recover last good backup")
		t.check_eq(service.last_notice,"toast.save_repaired","repair notice")
		var quarantines := 0
		for file in DirAccess.get_files_at(service.save_path.get_base_dir()):
			if ".corrupt." in file:
				quarantines+=1
				t.check_eq(FileAccess.get_file_as_string(service.save_path.get_base_dir()+"/"+file),corrupt,"quarantine retains exact bytes")
		t.check_eq(quarantines,1,"one quarantine")
		t.check(service.save_game(service.profile,true),"save recovered profile")
		service.free()
	var no_backup = SaveTools.service("no_backup")
	SaveTools.write(no_backup.save_path,"unreadable")
	t.check_eq(no_backup.load_game(),SaveSchema.defaults(),"defaults without backup")
	t.check_eq(no_backup.last_notice,"toast.save_unreadable","new profile notice")
	no_backup.free()
	var future = SaveTools.service("future")
	var raw := '{"schema":3,"data":{"special":"keep"}}'
	SaveTools.write(future.save_path,raw)
	future.load_game()
	t.check(future.saving_disabled,"future version disables saving")
	t.check_eq(future.last_notice,"toast.save_future","future warning")
	future.last_save_succeeded=true
	t.check(not future.save_game(SaveSchema.defaults(),true),"future save rejected")
	t.check(not future.last_save_succeeded,"future-schema rejection clears stale save-success status")
	t.check_eq(FileAccess.get_file_as_string(future.save_path),raw,"future bytes unchanged")
	future.free()
