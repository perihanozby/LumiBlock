extends Node2D

const BoardModelScript = preload("res://scripts/board_model.gd")
const PieceCatalogScript = preload("res://scripts/piece_catalog.gd")
const PieceModelScript = preload("res://scripts/piece_model.gd")
const ScoringEngineScript = preload("res://scripts/scoring_engine.gd")
const BG := Color("0b1322")
const PANEL := Color("18202f")
const EMPTY := Color("131d31")
const ACCENTS: Array[Color] = [Color("8083ff"), Color("44e2cd"), Color("ff7188"), Color("fbbf24")]

var board: BoardModel = BoardModelScript.new()
var rng := RandomNumberGenerator.new()
var tray: Array[PieceModel] = []
var score := 0
var best := 0
var combo := 0
var screen := "home"
var has_saved_session := false
var game_mode := "classic"
var daily_date := ""
var daily_lines := 0
var saved_sessions: Dictionary = {}
var dragging := -1
var drag_position := Vector2.ZERO
var active_input_source := ""
var last_input_tick := 0
var stats := {"games": 0, "lines": 0, "best_combo": 0, "play_time": 0.0}
var settings := {"sound": true, "music": true, "haptics": true, "reduced_effects": false, "language": "en"}

func _ready() -> void:
	rng.seed = Time.get_unix_time_from_system()
	var saved: Dictionary = SaveService.load_legacy_game()
	if not saved.is_empty():
		best = int(saved.get("best", 0)); stats = saved.get("stats", stats); settings = saved.get("settings", settings)
		saved_sessions = saved.get("sessions", {}) if saved.get("sessions", {}) is Dictionary else {}
		if saved.has("session") and not saved_sessions.has("classic"): saved_sessions["classic"] = saved.session
		var resume_mode := str(saved.get("active_mode", "classic"))
		if saved_sessions.has(resume_mode) and saved_sessions[resume_mode] is Dictionary: _restore_session(saved_sessions[resume_mode])
	TranslationServer.set_locale(str(settings.get("language", "en")))
	queue_redraw()

func _process(delta: float) -> void:
	stats.play_time += delta if screen == "game" else 0.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(390, 844)), BG)
	draw_circle(Vector2(195, 170), 220.0, Color(0.25, 0.27, 0.95, 0.08))
	draw_circle(Vector2(195, 650), 180.0, Color(0.05, 0.85, 0.75, 0.045))
	if screen == "home": _draw_home()
	elif screen == "game": _draw_game()
	elif screen == "pause": _draw_game(); _draw_pause()
	elif screen == "daily": _draw_daily()
	elif screen == "stats": _draw_stats()
	elif screen == "settings": _draw_settings()
	elif screen == "over": _draw_game_over()

func _text(value: String, pos: Vector2, size: int, color: Color = Color("dbe2f8")) -> void:
	draw_string(ThemeDB.fallback_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _panel(rect: Rect2, color: Color = PANEL) -> void:
	draw_style_box(_box(color, 18, Color(1, 1, 1, 0.08)), rect)

func _box(color: Color, radius: int, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var box := StyleBoxFlat.new(); box.bg_color = color; box.corner_radius_top_left = radius; box.corner_radius_top_right = radius; box.corner_radius_bottom_left = radius; box.corner_radius_bottom_right = radius; box.border_width_left = 1; box.border_width_right = 1; box.border_width_top = 1; box.border_width_bottom = 1; box.border_color = border; return box

func _draw_cube(rect: Rect2, base_color: Color, alpha: float = 1.0) -> void:
	var color := Color(base_color, alpha)
	draw_style_box(_box(color, 7, Color(1, 1, 1, 0.16 * alpha)), rect)
	var top := PackedVector2Array([rect.position + Vector2(4, 3), rect.position + Vector2(rect.size.x - 5, 3), rect.position + Vector2(rect.size.x - 10, 9), rect.position + Vector2(9, 9)])
	draw_colored_polygon(top, Color(1, 1, 1, 0.18 * alpha))
	var side := PackedVector2Array([rect.position + Vector2(rect.size.x - 5, 3), rect.position + Vector2(rect.size.x - 1, 8), rect.position + Vector2(rect.size.x - 1, rect.size.y - 7), rect.position + Vector2(rect.size.x - 10, rect.size.y - 1), rect.position + Vector2(rect.size.x - 10, 9)])
	draw_colored_polygon(side, Color(0, 0, 0, 0.18 * alpha))
	draw_line(rect.position + Vector2(7, 4), rect.position + Vector2(rect.size.x - 7, 4), Color(1, 1, 1, 0.28 * alpha), 1.0)

func _button(rect: Rect2, label: String, accent: Color = Color("6366f1")) -> void:
	draw_style_box(_box(accent, 18), rect)
	var label_size := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	_text(label, rect.position + Vector2((rect.size.x - label_size.x) / 2.0, (rect.size.y + label_size.y) / 2.0), 16, Color("07101d"))

func _draw_home() -> void:
	_text("LUMIBLOCK", Vector2(24, 58), 28, Color("c0c1ff")); _text("AURORA SANCTUARY", Vector2(26, 80), 11, Color("44e2cd")); _draw_brand_cubes(Vector2(302, 32))
	_panel(Rect2(20, 112, 350, 116)); _text("PERSONAL BEST", Vector2(38, 145), 12, Color("44e2cd")); _text(str(best), Vector2(36, 192), 46, Color("dbe2f8")); _text("Your local record", Vector2(230, 190), 12, Color("c7c4d7"))
	_button(Rect2(20, 250, 350, 66), "PLAY CLASSIC", Color("44e2cd")); _button(Rect2(20, 332, 350, 56), "DAILY CHALLENGE", Color("8083ff"))
	_panel(Rect2(20, 420, 350, 92)); _text("A calm, tactile puzzle sanctuary", Vector2(38, 456), 17); _text("Place blocks. Clear lines. Find your flow.", Vector2(38, 484), 13, Color("c7c4d7"))
	_button(Rect2(20, 548, 106, 48), "STATS", Color("2d3545")); _button(Rect2(142, 548, 106, 48), "SETTINGS", Color("2d3545")); _button(Rect2(264, 548, 106, 48), "RESUME", Color("2d3545"))
	_panel(Rect2(20, 624, 350, 88), Color("141c2b")); _text("TODAY'S FLOW", Vector2(38, 655), 12, Color("44e2cd")); _text(str(daily_lines) + " / 40 lines", Vector2(38, 690), 23); _text("Daily progress on this device", Vector2(210, 688), 11, Color("c7c4d7"))
	_text("Offline-first • No ads", Vector2(120, 790), 12, Color("908fa0"))

func _draw_brand_cubes(origin: Vector2) -> void:
	_draw_cube(Rect2(origin, Vector2(24, 24)), ACCENTS[0])
	_draw_cube(Rect2(origin + Vector2(28, 0), Vector2(24, 24)), ACCENTS[1])
	_draw_cube(Rect2(origin + Vector2(0, 28), Vector2(24, 24)), ACCENTS[2])
	_draw_cube(Rect2(origin + Vector2(28, 28), Vector2(24, 24)), ACCENTS[3])

func _draw_game() -> void:
	_text("DAILY" if game_mode == "daily" else "CLASSIC", Vector2(24, 48), 18, Color("c0c1ff")); _text("SCORE  " + str(score), Vector2(24, 84), 30); _text("BEST  " + str(best), Vector2(260, 78), 13, Color("c7c4d7")); _text("☰", Vector2(350, 50), 26)
	var origin := Vector2(22, 130); var cell := 43.0
	for y in 8:
		for x in 8:
			var value: int = board.cells[y][x]; var color: Color = EMPTY if value == -1 else ACCENTS[value]
			_draw_cube(Rect2(origin + Vector2(x, y) * cell, Vector2(39, 39)), color)
	_text("SELECT A SHAPE", Vector2(24, 505), 12, Color("44e2cd"))
	for i in tray.size():
		_panel(Rect2(18 + i * 120, 532, 108, 114), Color("141c2b"))
		if tray[i] != null and i != dragging: _draw_piece(tray[i], Vector2(40 + i * 120, 558), 22.0)
	if dragging >= 0 and dragging < tray.size() and tray[dragging] != null: _draw_drag_preview(tray[dragging])
	_text("Drag a piece onto the board", Vector2(105, 690), 13, Color("c7c4d7"))
	_button(Rect2(20, 742, 160, 48), "PAUSE", Color("2d3545")); _button(Rect2(210, 742, 160, 48), "HOME", Color("2d3545"))

func _draw_piece(piece: PieceModel, pos: Vector2, cell: float) -> void:
	for p in piece.shape: _draw_cube(Rect2(pos + Vector2(p) * cell, Vector2(cell - 3, cell - 3)), ACCENTS[piece.color])

func _draw_daily() -> void:
	_text("DAILY CHALLENGE", Vector2(24, 58), 24, Color("c0c1ff")); _panel(Rect2(20, 100, 350, 220)); _text(Time.get_date_string_from_system(), Vector2(40, 145), 18); _text("A fresh deterministic board every day.", Vector2(40, 180), 14, Color("c7c4d7")); _text("Progress: " + str(daily_lines) + " / 40 lines", Vector2(40, 230), 20, Color("44e2cd")); _button(Rect2(20, 350, 350, 60), "PLAY DAILY", Color("8083ff")); _button(Rect2(20, 440, 350, 52), "BACK", Color("2d3545"))

func _draw_stats() -> void:
	_text("STATISTICS", Vector2(24, 58), 28, Color("c0c1ff")); var labels: Array[String] = ["Games played", "Best score", "Lines cleared", "Highest combo", "Play time"]
	var vals: Array[String] = [str(stats.games), str(best), str(stats.lines), str(stats.best_combo), "%dm" % int(stats.play_time / 60.0)]
	for i in labels.size(): _panel(Rect2(20, 100 + i * 78, 350, 60)); _text(labels[i], Vector2(38, 136 + i * 78), 15, Color("c7c4d7")); _text(vals[i], Vector2(280, 138 + i * 78), 20, Color("44e2cd"))
	_button(Rect2(20, 530, 350, 52), "BACK", Color("2d3545"))

func _draw_settings() -> void:
	_text("SETTINGS", Vector2(24, 58), 28, Color("c0c1ff")); var items := ["Sound", "Music", "Haptics", "Reduced effects", "Language: " + str(settings.language)]
	var toggles: Array[bool] = [settings.sound, settings.music, settings.haptics, settings.reduced_effects]
	for i in items.size(): _panel(Rect2(20, 100 + i * 70, 350, 54)); _text(items[i], Vector2(38, 134 + i * 70), 16); _text(("ON" if toggles[i] else "OFF") if i < 4 else "CHANGE", Vector2(292, 134 + i * 70), 12, Color("44e2cd"))
	_button(Rect2(20, 500, 350, 52), "BACK", Color("2d3545"))

func _draw_game_over() -> void:
	_text("FLOW COMPLETE", Vector2(70, 180), 30, Color("c0c1ff")); _panel(Rect2(28, 240, 334, 210)); _text("SCORE", Vector2(145, 290), 13, Color("44e2cd")); _text(str(score), Vector2(110, 350), 52); _text("PERSONAL BEST  " + str(best), Vector2(105, 390), 13, Color("c7c4d7")); _button(Rect2(28, 490, 334, 58), "PLAY AGAIN", Color("44e2cd")); _button(Rect2(28, 570, 334, 52), "HOME", Color("2d3545"))

func _draw_pause() -> void:
	draw_rect(Rect2(0, 0, 390, 844), Color(0.02, 0.04, 0.08, 0.82))
	_panel(Rect2(28, 220, 334, 320), Color("101827")); _text("PAUSED", Vector2(126, 275), 30, Color("c0c1ff")); _text("Your progress is safely saved.", Vector2(82, 310), 13, Color("c7c4d7"))
	_button(Rect2(52, 350, 286, 54), "RESUME", Color("44e2cd")); _button(Rect2(52, 420, 286, 54), "RESTART", Color("8083ff")); _button(Rect2(52, 490, 286, 40), "HOME", Color("2d3545"))

func _draw_drag_preview(piece: PieceModel) -> void:
	var origin := _board_origin_from_pointer(drag_position)
	var valid := board.can_place(piece.shape, origin)
	var preview_color := ACCENTS[piece.color] if valid else Color("ff7188")
	for cell in piece.shape:
		var board_cell := origin + cell
		if board_cell.x >= 0 and board_cell.x < BoardModel.SIZE and board_cell.y >= 0 and board_cell.y < BoardModel.SIZE:
			_draw_cube(Rect2(Vector2(22, 130) + Vector2(board_cell) * 43.0, Vector2(39, 39)), preview_color, 0.72)
	var lift := Vector2(-piece.shape[0].x * 22.0, -58.0)
	_draw_piece(piece, drag_position + lift, 22.0)

func _board_origin_from_pointer(pos: Vector2) -> Vector2i:
	return Vector2i(floor((pos.x - 22) / 43.0), floor((pos.y - 130) / 43.0))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE: _go_home(); return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if active_input_source == "touch" and Time.get_ticks_msec() - last_input_tick < 300: return
		active_input_source = "mouse"; last_input_tick = Time.get_ticks_msec()
		if event.pressed: _pointer_down(event.position)
		else: _pointer_up(event.position)
		return
	if event is InputEventScreenTouch:
		active_input_source = "touch"; last_input_tick = Time.get_ticks_msec()
		if event.pressed: _pointer_down(event.position)
		else: _pointer_up(event.position)
		return
	if event is InputEventScreenDrag and active_input_source == "touch" and dragging >= 0:
		drag_position = event.position; queue_redraw(); return
	if event is InputEventMouseMotion and active_input_source == "mouse" and dragging >= 0:
		drag_position = event.position; queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and dragging >= 0:
		dragging = -1; active_input_source = ""; queue_redraw()

func _pointer_down(pos: Vector2) -> void:
	if screen == "home":
		if Rect2(20, 250, 350, 66).has_point(pos): _start_game(false)
		elif Rect2(20, 332, 350, 56).has_point(pos): _start_game(true)
		elif Rect2(20, 420, 350, 100).has_point(pos): screen = "daily"
		elif Rect2(20, 548, 120, 48).has_point(pos): screen = "stats"
		elif Rect2(142, 548, 120, 48).has_point(pos): screen = "settings"
		elif Rect2(264, 548, 120, 48).has_point(pos) and has_saved_session: screen = "game"
	elif screen == "game":
		if Rect2(18, 532, 350, 114).has_point(pos):
			var slot := clampi(int((pos.x - 18) / 120), 0, 2)
			if slot < tray.size() and tray[slot] != null: dragging = slot; drag_position = pos
		elif Rect2(20, 742, 160, 48).has_point(pos): _save_session(true); screen = "pause"
		elif Rect2(210, 742, 160, 48).has_point(pos): _save_session(true); screen = "home"
	elif screen == "pause":
		if Rect2(52, 350, 286, 54).has_point(pos): screen = "game"
		elif Rect2(52, 420, 286, 54).has_point(pos): _start_game(false)
		elif Rect2(52, 490, 286, 40).has_point(pos): screen = "home"
	elif screen == "daily":
		if Rect2(20, 350, 350, 60).has_point(pos): _start_game(true)
		elif Rect2(20, 440, 350, 52).has_point(pos): _go_home()
	elif screen == "stats":
		if Rect2(20, 530, 350, 52).has_point(pos): _go_home()
	elif screen == "settings":
		if Rect2(20, 100, 350, 54).has_point(pos): settings.sound = not settings.sound; _save_session(false)
		elif Rect2(20, 170, 350, 54).has_point(pos): settings.music = not settings.music; _save_session(false)
		elif Rect2(20, 240, 350, 54).has_point(pos): settings.haptics = not settings.haptics; _save_session(false)
		elif Rect2(20, 310, 350, 54).has_point(pos): settings.reduced_effects = not settings.reduced_effects; _save_session(false)
		elif Rect2(20, 380, 350, 54).has_point(pos): _cycle_language(); _save_session(false)
		elif Rect2(20, 500, 350, 52).has_point(pos): _go_home()
	elif screen == "over":
		if Rect2(28, 490, 334, 58).has_point(pos): _start_game(false)
		elif Rect2(28, 570, 334, 52).has_point(pos): _go_home()

func _pointer_up(pos: Vector2) -> void:
	if screen != "game" or dragging < 0 or dragging >= tray.size() or tray[dragging] == null: return
	var origin: Vector2i = Vector2i(floor((pos.x - 22) / 43.0), floor((pos.y - 130) / 43.0)); var piece: PieceModel = tray[dragging]
	if board.can_place(piece.shape, origin):
		var result: Dictionary = board.place(piece.shape, origin, piece.color)
		combo = combo + 1 if result.lines > 0 else 0
		score += ScoringEngineScript.gain(piece.shape.size(), result.lines, combo, result.lines > 0 and board.is_empty())
		stats.lines += result.lines
		if game_mode == "daily": daily_lines += result.lines
		stats.best_combo = maxi(stats.best_combo, combo)
		tray[dragging] = null
		if tray.all(func(value): return value == null): tray = PieceCatalogScript.generate(rng)
		if score > best: best = score
		if not board.has_any_move(_tray_shapes()): screen = "over"; has_saved_session = false; stats.games += 1
	dragging = -1; queue_redraw(); _save_session()

func _start_game(daily: bool) -> void:
	game_mode = "daily" if daily else "classic"; daily_date = Time.get_date_string_from_system() if daily else ""
	if daily: rng.seed = int(daily_date.replace("-", "")); daily_lines = 0
	else: rng.randomize()
	board.clear(); score = 0; combo = 0; tray = PieceCatalogScript.generate(rng); screen = "game"; has_saved_session = true; queue_redraw()

func _go_home() -> void:
	dragging = -1; screen = "home"; _save_session(false); queue_redraw()

func _save_session(active_session: bool = screen == "game" or screen == "pause") -> void:
	var serialized_tray: Array = []
	for piece in tray: serialized_tray.append(null if piece == null else piece.to_dict())
	var current_session := {"active": has_saved_session, "state": "active" if has_saved_session else "finished", "mode": game_mode, "date": daily_date, "daily_lines": daily_lines, "rng_state": rng.state, "screen": "game", "score": score, "combo": combo, "board": board.to_dict(), "tray": serialized_tray}
	saved_sessions[game_mode] = current_session
	SaveService.save_legacy_game({"best": best, "stats": stats, "settings": settings, "active_mode": game_mode, "sessions": saved_sessions}, true)

func _cycle_language() -> void:
	var languages: Array[String] = ["en", "tr", "es", "pt-BR", "fr", "de", "it", "ja", "ko", "zh-CN", "ar", "hi", "id", "vi", "ru", "th"]
	var current := languages.find(str(settings.language))
	settings.language = languages[(current + 1) % languages.size()]
	TranslationServer.set_locale(settings.language)

func _restore_session(session: Dictionary) -> void:
	has_saved_session = false
	if str(session.get("state", "active" if session.get("active", false) else "finished")) != "active": return
	game_mode = str(session.get("mode", "classic")); daily_date = str(session.get("date", "")); daily_lines = int(session.get("daily_lines", 0)); score = int(session.get("score", 0)); combo = int(session.get("combo", 0)); rng.state = int(session.get("rng_state", rng.state)); board.from_dict(session.get("board", {})); tray.clear()
	var raw_tray: Variant = session.get("tray", [])
	if raw_tray is Array:
		for slot in 3:
			var raw_piece: Variant = raw_tray[slot] if slot < raw_tray.size() else null
			var restored_piece: PieceModel = null
			if raw_piece is Dictionary:
				restored_piece = PieceModelScript.from_dict(raw_piece)
				if restored_piece.shape.is_empty(): restored_piece = null
			tray.append(restored_piece)
	if tray.is_empty() or tray.all(func(value): return value == null): tray = PieceCatalogScript.generate(rng)
	has_saved_session = board.has_any_move(_tray_shapes()); screen = "home"

func _tray_shapes() -> Array:
	var shapes: Array = []
	for piece in tray:
		if piece != null: shapes.append(piece.shape)
	return shapes
