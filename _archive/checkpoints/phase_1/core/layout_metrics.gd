class_name LayoutMetrics
extends RefCounted

static func compute(viewport: Vector2, safe_area: Rect2 = Rect2()) -> Dictionary:
	var safe := safe_area if safe_area.has_area() else Rect2(Vector2.ZERO, viewport)
	var avail_w := safe.size.x - 32.0
	var board_side := minf(520, avail_w)
	# Solve the tray/board dependency to a stable value rather than using a stale tray height.
	for i in 12:
		var tray_h := clampf(0.30 * board_side,104,132)
		board_side = minf(minf(520, avail_w), safe.size.y - (88 + 28 + 12 + tray_h + 16 + 16))
	board_side = maxf(0,board_side)
	var tray_height := clampf(0.3 * board_side,104,132)
	var origin := Vector2(safe.position.x + (safe.size.x-board_side)/2, safe.position.y+128)
	var slots: Array[Rect2] = []
	var slot_width := (avail_w-16)/3
	for i in 3: slots.append(Rect2(Vector2(safe.position.x+16+i*(slot_width+8),origin.y+board_side+16),Vector2(slot_width,tray_height)))
	return {"board_rect":Rect2(origin,Vector2.ONE*board_side),"board_side":board_side,"pitch":maxf(0,(board_side-16)/8),"board_origin":origin+Vector2(8,8),"slots":slots,"status_height":28,"safe_area":safe}
