class_name PieceGenerator
extends RefCounted

const DAILY := "daily"
static var catalog: Dictionary = {}

static func make_piece(id: String, color: int) -> PieceModel:
	if catalog.is_empty(): catalog = PieceCatalog.entries()
	var shape: Array[Vector2i] = []
	shape.assign(catalog.get(id, []))
	var piece := PieceModel.new(shape, color)
	piece.shape_id = id
	return piece

static func next_piece(board: BoardModel, rng: SeededRng, context: Dictionary) -> PieceModel:
	if catalog.is_empty(): catalog = PieceCatalog.entries()
	var weights: Array = [4.0,12.0,24.0,30.0,20.0,10.0]
	var daily: bool = context.get("mode", "classic") == DAILY
	if not daily:
		if int(context.get("pieces", 0)) < 10: weights[5] = 0.0
		if board.occupancy() > 0.60:
			for i in 3: weights[i] *= 1.8
	var bucket := rng.pick_weighted(weights) + 1
	var options: Array = []
	for id in catalog:
		if mini(catalog[id].size(), 6) == bucket and id != "sq3": options.append(id)
	var id: String
	# sq3 is 1.5% of the >=6 bucket (the tighter reading of the request).
	if bucket == 6 and rng.next_float() < 0.015: id = "sq3"
	else: id = options[rng.range_int(0, options.size() - 1)]
	return make_piece(id, rng.range_int(0, 4))

static func next_tray(board: BoardModel, rng: SeededRng, context: Dictionary = {}) -> Array[PieceModel]:
	var tray: Array[PieceModel] = []
	for attempt in 13:
		tray.clear()
		for i in 3: tray.append(next_piece(board, rng, context))
		if tray[0].shape_id == tray[1].shape_id and tray[1].shape_id == tray[2].shape_id:
			tray[2] = make_piece("dom_h" if tray[0].shape_id == "mono" else "mono", tray[2].color)
		if tray[0].color == tray[1].color and tray[1].color == tray[2].color: tray[2].color = (tray[2].color + 1) % 5
		if context.get("mode", "classic") == DAILY: return tray
		if board.has_any_move([tray[0].shape,tray[1].shape,tray[2].shape]):
			if board.occupancy() < 0.5: return tray
			var deadline := Time.get_ticks_usec() + 3000
			if all_fit(board, tray, deadline) or Time.get_ticks_usec() >= deadline: return tray
	# On a full uncleared board no piece can fit; the session reports game over.
	tray[0] = make_piece("mono", (tray[1].color + 1) % 5)
	if tray[1].shape_id == "mono" and tray[2].shape_id == "mono": tray[2] = make_piece("dom_h", tray[2].color)
	return tray

static func all_fit(board: BoardModel, tray: Array, deadline: int) -> bool:
	if tray.is_empty(): return true
	for i in tray.size():
		for y in 8:
			for x in 8:
				if Time.get_ticks_usec() >= deadline: return false
				if not board.can_place(tray[i].shape, Vector2i(x,y)): continue
				var copy := BoardModel.new()
				copy.from_dict(board.to_dict())
				copy.place(tray[i].shape, Vector2i(x,y), tray[i].color)
				var remaining := tray.duplicate()
				remaining.remove_at(i)
				if all_fit(copy, remaining, deadline): return true
	return false
