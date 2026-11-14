class_name DailyChallenge
extends RefCounted

static func fnv1a32(value: String) -> int:
	var result := 2166136261
	for byte in value.to_utf8_buffer(): result = SeededRng.mul32(result ^ byte, 16777619)
	return result

static func describe(date: String) -> Dictionary:
	var seed_value := fnv1a32("LUMIBLOCK-DAILY-" + date)
	var template := seed_value % 3
	var target := 16 + ((seed_value >> 3) % 9)
	if template == 1: target = 2500 + 250 * ((seed_value >> 3) % 9)
	elif template == 2: target = 3 + ((seed_value >> 3) % 3)
	return {"date": date, "seed": seed_value, "template": template, "target": target}

static func start_board(date: String) -> BoardModel:
	var board := BoardModel.new()
	var rng := SeededRng.new(int(describe(date).seed) ^ 0x9e3779b9)
	var count := rng.range_int(10,18)
	var placed := 0
	while placed < count:
		var x := rng.range_int(0,7)
		var y := rng.range_int(0,7)
		if board.cells[y][x] != -1: continue
		board.cells[y][x] = rng.range_int(0,4)
		var row_full := board.cells[y].count(-1) == 0
		var col_full := true
		for row in board.cells:
			if row[x] == -1: col_full = false
		if row_full or col_full: board.cells[y][x] = -1
		else: placed += 1
	return board

static func expire_if_stale(session: GameSession, today: String) -> bool:
	if session.mode == "daily" and session.state == "active" and session.date != today:
		session.finish("expired")
		return true
	return false

static func current_streak(last_date: String, saved_streak: int, today: String) -> int:
	if last_date.is_empty(): return 0
	var difference := Time.get_unix_time_from_datetime_string(today)-Time.get_unix_time_from_datetime_string(last_date)
	return saved_streak if difference>=0 and difference<=86400 else 0
