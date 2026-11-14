class_name StatsTracker
extends RefCounted

var processed: Dictionary = {}

func finish(session: GameSession, data: Dictionary) -> bool:
	if session.state != "finished" or processed.has(session.id): return false
	for previous in data.get("history",[]):
		if previous.get("id", "") == session.id: return false
	processed[session.id] = true
	var stats: Dictionary = data.stats
	stats.games_abandoned += 1 if session.result == "abandoned" else 0
	stats.games_finished += 0 if session.result == "abandoned" else 1
	stats.lines_cleared += session.lines
	stats.pieces_placed += session.pieces
	stats.play_seconds += int(session.elapsed_s)
	stats.perfect_clears=int(stats.get("perfect_clears",0))+int(session.extra_fields.get("perfect_clears",0))
	var key := "best_daily" if session.mode == "daily" else "best_classic"
	data.records[key] = maxi(data.records[key],session.score)
	data.records.best_combo = maxi(data.records.best_combo,session.max_combo)
	if session.mode == "daily" and session.result == "completed" and not data.daily.completed.has(session.date):
		data.daily.completed[session.date] = {"score":session.score,"seconds":session.elapsed_s,"ts":int(Time.get_unix_time_from_system())}
		stats.daily_completed += 1
		var previous_date := str(data.daily.get("last_streak_date",""))
		var consecutive := not previous_date.is_empty() and Time.get_unix_time_from_datetime_string(session.date)-Time.get_unix_time_from_datetime_string(previous_date)==86400
		stats.daily_streak = stats.daily_streak+1 if consecutive else 1
		stats.daily_best_streak = maxi(stats.daily_best_streak,stats.daily_streak)
		data.daily.last_streak_date = session.date
	data.history.push_front({"id":session.id,"ts":int(Time.get_unix_time_from_system()),"date":session.date,"mode":session.mode,"score":session.score,"lines":session.lines,"max_combo":session.max_combo,"pieces":session.pieces,"seconds":int(session.elapsed_s),"result":session.result})
	data.history.resize(mini(30,data.history.size()))
	return true
