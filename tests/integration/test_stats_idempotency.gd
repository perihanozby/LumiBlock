extends RefCounted

const SaveTools = preload("res://tests/save_test_tools.gd")

func run(t) -> void:
	var data := {"stats":{"games_abandoned":0,"games_finished":0,"lines_cleared":0,"pieces_placed":0,"play_seconds":0,"daily_completed":0,"daily_streak":0,"daily_best_streak":0},"records":{"best_daily":0,"best_classic":0,"best_combo":0},"daily":{"completed":{},"last_streak_date":""},"history":[]}
	var tracker := StatsTracker.new()
	for day in ["2024-12-31","2025-01-01"]:
		var session := GameSession.new(1,"daily",day)
		session.score=500
		session.lines=4
		session.pieces=10
		session.elapsed_s=65
		session.finish("completed")
		t.check(tracker.finish(session,data),"first finish counted")
		t.check(not tracker.finish(session,data),"repeat finish ignored")
		t.check(not StatsTracker.new().finish(session,data),"persisted history guards duplicate after service restart")
	t.check_eq(data.stats.daily_streak,2,"streak crosses year")
	t.check_eq(data.stats.games_finished,2,"one finish per session")
	t.check_eq(data.stats.play_seconds,130,"elapsed accumulated")
	var replay := GameSession.new(1,"daily","2025-01-01")
	replay.score=9999
	replay.finish("completed")
	tracker.finish(replay,data)
	t.check_eq(data.daily.completed["2025-01-01"].score,500,"replay preserves first completion")
	t.check_eq(data.stats.daily_streak,2,"replay preserves streak")
	t.check_eq(data.stats.daily_completed,2,"replay does not add completion")
	t.check_eq(DailyChallenge.current_streak("2025-01-01",2,"2025-01-03"),0,"missed day resets silently")
	t.check_eq(DailyChallenge.current_streak("2025-01-01",2,"2025-01-02"),2,"yesterday retained")
	var active := GameSession.new(1,"daily","2025-01-01")
	t.check(DailyChallenge.expire_if_stale(active,"2025-01-02"),"rollover expires active daily")
	t.check_eq(active.result,"expired","expiry result")
	t.check(not DailyChallenge.expire_if_stale(active,"2025-01-03"),"expiry idempotent")
	var service = SaveTools.service("stats_finish_restore")
	var profile := SaveSchema.defaults()
	var classic := GameSession.new(14)
	classic.finish("over")
	tracker.finish(classic,profile)
	profile.sessions.classic=classic.to_dict()
	t.check(service.save_game(profile,true),"finished result persisted")
	var restored_profile: Dictionary = service.load_game()
	var restored := GameSession.from_dict(restored_profile.sessions.classic)
	t.check(not StatsTracker.new().finish(restored,restored_profile),"reopening persisted game-over result does not recount")
	t.check_eq(restored_profile.stats.games_finished,1,"finished count survives reload once")
	service.free()
	var perfect:=GameSession.new(2)
	perfect.tray.assign([PieceGenerator.make_piece("mono",0),PieceGenerator.make_piece("mono",1),PieceGenerator.make_piece("mono",2)])
	for x in range(1,8): perfect.board.cells[0][x]=0
	perfect.place(0,Vector2i.ZERO)
	t.check_eq(perfect.extra_fields.get("perfect_clears",0),1,"perfect clear counted in session")
	var perfect_profile:=SaveSchema.defaults()
	perfect.finish("over")
	StatsTracker.new().finish(perfect,perfect_profile)
	t.check_eq(perfect_profile.stats.perfect_clears,1,"perfect clear accumulated once in totals")
