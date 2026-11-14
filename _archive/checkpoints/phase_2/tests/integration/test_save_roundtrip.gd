extends RefCounted

func run(t) -> void:
	var service = SaveTestTools.service("roundtrip")
	var data := SaveSchema.defaults()
	data.sessions.classic=GameSession.new(44).to_dict()
	data.sessions.daily=GameSession.new(55,"daily","2026-11-14").to_dict()
	data.sessions.classic.extra_session="keep session extension"
	data.sessions.classic.tray[0].extra_piece="keep piece extension"
	data.settings.language="tr"
	data.settings.custom_flag="keep me"
	data.custom_root={"integer":5,"decimal":0.125}
	data.history=[{"id":"completed-test-session","ts":1794614400,"mode":"classic","score":500,"lines":3,"max_combo":2,"pieces":15,"seconds":123,"result":"over","extra_history":"preserve"}]
	data.daily.completed["2026-11-13"]={"score":500,"seconds":123,"ts":1794614400}
	data.daily.last_streak_date="2026-11-13"
	data.stats.games_finished=1
	data.stats.daily_completed=1
	data=SaveSchema.validate(data)
	t.check(service.save_game(data,true),"initial save succeeds")
	t.check_eq(service.load_game(),data,"roundtrip all data/session/settings")
	t.check_eq(GameSession.from_dict(service.profile.sessions.classic).to_dict(),data.sessions.classic,"session edits retain unknown extensions")
	var original := FileAccess.get_file_as_string(service.save_path)
	data.records.best_classic=900
	t.check(service.save_game(data,true),"Windows replace existing succeeds")
	t.check_eq(FileAccess.get_file_as_string(service._backup_path()),original,"backup exact previous main")
	t.check_eq(service.load_game().records.best_classic,900,"load replaced main")
	service.free()
