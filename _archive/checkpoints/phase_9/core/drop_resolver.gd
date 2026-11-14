class_name DropResolver
extends RefCounted

static func resolve(pointer: Vector2, cells: Array[Vector2i], bbox: Vector2i, pitch: float, board_origin: Vector2, board: BoardModel, assist: bool = true, prev_origin: Variant = null, safe_area: Rect2 = Rect2(0,0,390,844)) -> Dictionary:
	if pitch <= 0: return {"valid":false,"over_board":false,"origin":Vector2i(-99,-99),"visual_top_left":pointer}
	var extent := Vector2(bbox)*pitch
	var top_left := Vector2(pointer.x-extent.x/2,pointer.y-extent.y-0.9*pitch)
	top_left.x = clampf(top_left.x,safe_area.position.x,maxf(safe_area.position.x,safe_area.end.x-extent.x))
	top_left.y = clampf(top_left.y,safe_area.position.y,maxf(safe_area.position.y,safe_area.end.y-extent.y))
	var grid := (top_left-board_origin)/pitch
	var origin := Vector2i(roundi(grid.x),roundi(grid.y))
	if prev_origin is Vector2i and absf(grid.x-prev_origin.x)<=0.62 and absf(grid.y-prev_origin.y)<=0.62: origin = prev_origin
	if assist and not board.can_place(cells,origin):
		var candidates: Array[Vector2i] = []
		for y in range(origin.y-1,origin.y+2):
			for x in range(origin.x-1,origin.x+2):
				var candidate := Vector2i(x,y)
				if Vector2(candidate).distance_to(grid)<=0.75 and board.can_place(cells,candidate): candidates.append(candidate)
		candidates.sort_custom(func(a: Vector2i,b: Vector2i):
			var da := Vector2(a).distance_squared_to(grid)
			var db := Vector2(b).distance_squared_to(grid)
			return a.y < b.y or (a.y==b.y and a.x<b.x) if is_equal_approx(da,db) else da<db)
		if not candidates.is_empty(): origin = candidates[0]
	var over := false
	for cell in cells:
		var p := origin+cell
		if p.x>=0 and p.x<8 and p.y>=0 and p.y<8: over = true
	return {"visual_top_left":top_left,"origin":origin,"valid":board.can_place(cells,origin),"over_board":over}
