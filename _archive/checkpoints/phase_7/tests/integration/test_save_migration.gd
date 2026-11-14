extends RefCounted

func run(t) -> void:
	for filename in DirAccess.get_files_at("res://tests/fixtures"):
		if not filename.begins_with("save_v1_") or not filename.ends_with(".json"): continue
		var service = SaveTestTools.service("migration")
		var raw := FileAccess.get_file_as_string("res://tests/fixtures/"+filename)
		SaveTestTools.write(service.save_path,raw)
		var data: Dictionary = service.load_game()
		t.check(data.settings is Dictionary and data.stats is Dictionary,"fixture loads " + filename)
		if "corrupt" in filename:
			t.check_eq(service.last_notice,"toast.save_unreadable","corrupt fixture retained")
		else:
			var backup: String = service.save_path.get_basename()+".v1.bak.json"
			t.check_eq(FileAccess.get_file_as_string(backup),raw,"v1 backup exact")
			t.check(service.save_game(data,true),"migrated v2 save")
			service.load_game()
			t.check_eq(FileAccess.get_file_as_string(backup),raw,"one-time backup unchanged")
		service.free()
	var healthy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v1_healthy.json"))
	var migrated := SaveMigrations.from_v1(healthy)
	t.check_eq(migrated.records.best_classic,1234,"best mapping")
	t.check_eq(migrated.stats.games_finished,3,"games mapping")
	t.check_eq(migrated.settings.language,"en","explicit English remains English")
	t.check_eq(migrated.sessions.classic.tray[0].shape_id,"l3_0","legacy coordinate shape id")
	t.check_eq(migrated.sessions.classic.rng_state,0,"unsafe RNG discarded")
	t.check_eq(migrated.sessions.classic.stream_index,0,"stream reset")
