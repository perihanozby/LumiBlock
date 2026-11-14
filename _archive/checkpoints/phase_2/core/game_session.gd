class_name GameSession
extends RefCounted

signal piece_placed
signal lines_cleared(info)
signal score_changed(old, current)
signal combo_changed
signal tray_refilled
signal game_over(result)
signal mission_progress

var board := BoardModel.new()
var tray: Array[PieceModel] = []
var score := 0
var streak := 0
var grace := 0
var lines := 0
var pieces := 0
var max_combo := 0
var elapsed_s := 0.0
var state := "active"
var mode := "classic"
var date := ""
var result := ""
var rng := SeededRng.new()
var stream_index := 0
var started_at := 0
var id := ""
var extra_fields: Dictionary = {}
var tray_extensions: Array = [{},{},{}]

func _init(seed_value: int = 1, p_mode: String = "classic", p_date: String = "") -> void:
	mode = p_mode
	date = p_date
	started_at = int(Time.get_unix_time_from_system())
	id = "%d-%d-%d" % [started_at, Time.get_ticks_usec(), seed_value]
	if mode == "daily":
		seed_value = DailyChallenge.describe(date).seed
		board = DailyChallenge.start_board(date)
	rng = SeededRng.new(seed_value)
	refill()

func refill() -> void:
	tray = PieceGenerator.next_tray(board, rng, {"mode": mode, "pieces": pieces})
	tray_extensions=[{},{},{}]
	stream_index += 3
	tray_refilled.emit()

func tick(delta: float) -> void:
	if state == "active": elapsed_s += maxf(0, delta)

func place(slot: int, origin: Vector2i) -> Dictionary:
	if state != "active" or slot < 0 or slot >= tray.size() or tray[slot] == null: return {"valid": false}
	var piece := tray[slot]
	var info := board.place(piece.shape, origin, piece.color)
	if not info.valid: return info
	var old := score
	var combo := ScoringEngine.advance(streak, grace, info.lines)
	streak = combo.streak
	grace = combo.grace
	lines += info.lines
	pieces += 1
	max_combo = maxi(max_combo, streak)
	score += ScoringEngine.gain(piece.shape.size(), info.lines, streak, info.lines > 0 and board.is_empty())
	tray[slot] = null
	tray_extensions[slot]={}
	if tray.all(func(value): return value == null): refill()
	piece_placed.emit()
	if info.lines > 0: lines_cleared.emit(info)
	score_changed.emit(old, score)
	combo_changed.emit()
	mission_progress.emit()
	evaluate()
	return info

func finish(reason: String) -> void:
	if state != "active": return
	state = "finished"
	result = reason
	game_over.emit(reason)

func evaluate() -> void:
	if state != "active": return
	if mode == "daily":
		var mission := DailyChallenge.describe(date)
		var value: int = lines if mission.template == 0 else (score if mission.template == 1 else max_combo)
		if value >= mission.target:
			finish("completed")
			return
	var shapes: Array = []
	for piece in tray:
		if piece != null: shapes.append(piece.shape)
	if not board.has_any_move(shapes): finish("failed" if mode == "daily" else "over")

func to_dict() -> Dictionary:
	var saved_tray: Array = []
	for slot in tray.size():
		var piece := tray[slot]
		if piece==null: saved_tray.append(null)
		else:
			var entry: Dictionary = tray_extensions[slot].duplicate(true)
			entry.merge({"shape_id":piece.shape_id,"color":piece.color},true)
			saved_tray.append(entry)
	var data := extra_fields.duplicate(true)
	data.merge({"id": id,"state":state,"mode":mode,"date":date,"rng_state":rng.state,"stream_index":stream_index,"board":board.cells.duplicate(true),"tray":saved_tray,"score":score,"streak":streak,"grace":grace,"lines":lines,"pieces":pieces,"max_combo":max_combo,"elapsed_s":elapsed_s,"started_at":started_at,"result":result},true)
	return data

static func from_dict(data: Dictionary) -> GameSession:
	var session := GameSession.new(1, str(data.get("mode", "classic")), str(data.get("date", "")))
	session.extra_fields=data.duplicate(true)
	for key in ["id","state","score","streak","grace","lines","pieces","max_combo","elapsed_s","stream_index","started_at","result"]:
		if data.has(key): session.set(key, data[key])
	session.rng.state = int(data.get("rng_state",1)) & SeededRng.MASK
	session.board.from_dict({"cells":data.get("board",[])})
	session.tray.clear()
	var saved_tray: Array = data.get("tray",[]) if data.get("tray") is Array else []
	for slot in 3:
		var piece: Variant = saved_tray[slot] if slot < saved_tray.size() else null
		if piece is Dictionary and PieceCatalog.entries().has(piece.get("shape_id","")):
			session.tray.append(PieceGenerator.make_piece(piece.shape_id, clampi(int(piece.get("color",0)),0,4)))
			session.tray_extensions[slot]=piece.duplicate(true)
		else: session.tray.append(null)
	if session.state == "active" and session.tray.all(func(value): return value == null): session.refill()
	session.evaluate()
	return session
