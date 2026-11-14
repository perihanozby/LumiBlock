class_name SaveMigrations
extends RefCounted

static func from_v1(payload: Dictionary) -> Dictionary:
	var old: Dictionary = payload.get("data",payload) if payload.get("data",payload) is Dictionary else {}
	var result := SaveSchema.defaults()
	# Preserve unknown root fields; canonical v2 fields below win on collisions.
	for key in old:
		if not result.has(key): result[key]=old[key]
	result.records.best_classic=SaveSchema.nonnegative(old.get("best",0))
	var stats: Dictionary = old.get("stats",{}) if old.get("stats") is Dictionary else {}
	for mapping in [["games","games_finished"],["lines","lines_cleared"],["play_time","play_seconds"]]: result.stats[mapping[1]]=SaveSchema.nonnegative(stats.get(mapping[0],0))
	result.records.best_combo=SaveSchema.nonnegative(stats.get("best_combo",0))
	var settings: Dictionary = old.get("settings",{}) if old.get("settings") is Dictionary else {}
	for key in ["music","haptics","language"]:
		if settings.has(key): result.settings[key]=settings[key]
	if settings.has("sound"): result.settings.sfx=settings.sound
	if SaveSchema.boolean(settings.get("reduced_effects",false),false):
		result.settings.effects="minimal"
		result.settings.reduce_motion=true
	var sessions: Dictionary = old.get("sessions",{}).duplicate(true) if old.get("sessions") is Dictionary else {}
	if old.get("session") is Dictionary and not sessions.has("classic"): sessions.classic=old.session
	for mode in ["classic","daily"]:
		if not sessions.get(mode) is Dictionary: continue
		var source: Dictionary = sessions[mode]
		var date := str(source.get("date",""))
		var started := SaveSchema.nonnegative(source.get("started_at",0))
		var seed_value: int = DailyChallenge.describe(date).seed if mode=="daily" else started
		var session := GameSession.new(seed_value,mode,date)
		session.started_at=started
		session.id="migrated-%s-%s-%d" % [mode,date,started]
		session.state="active" if SaveSchema.boolean(source.get("active",false),false) else "finished"
		session.board.from_dict(source.get("board",{}) if source.get("board") is Dictionary else {})
		session.score=SaveSchema.nonnegative(source.get("score",0))
		session.streak=SaveSchema.nonnegative(source.get("combo",0))
		session.lines=SaveSchema.nonnegative(source.get("daily_lines",0))
		session.rng.state=seed_value
		session.stream_index=0
		session.tray.clear()
		var raw_tray: Array = source.get("tray",[]) if source.get("tray") is Array else []
		for i in 3:
			var entry: Variant = raw_tray[i] if i<raw_tray.size() else null
			var piece: PieceModel = null
			if entry is Dictionary:
				var restored := PieceModel.from_dict(entry)
				var id := PieceCatalog.id_for(restored.shape)
				if not id.is_empty(): piece=PieceGenerator.make_piece(id,restored.color)
			session.tray.append(piece)
		if session.state=="active" and session.tray.all(func(value): return value==null): session.refill()
		session.evaluate()
		result.sessions[mode]=session.to_dict()
	return SaveSchema.validate(result)
