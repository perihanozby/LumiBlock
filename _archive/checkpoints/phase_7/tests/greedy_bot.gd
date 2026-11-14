class_name GreedyBot
extends RefCounted

static var shape_masks: Dictionary = {}

static func move(session: GameSession) -> Dictionary:
	var best := {"slot":-1,"origin":Vector2i.ZERO}
	var best_value := -INF
	var rows: Array[int] = []
	for y in 8:
		var mask := 0
		for x in 8:
			if session.board.cells[y][x] != -1: mask |= 1 << x
		rows.append(mask)
	for slot in session.tray.size():
		var piece := session.tray[slot]
		if piece == null: continue
		var key := str(piece.shape)
		if not shape_masks.has(key):
			var width := 0
			var height := 0
			for cell in piece.shape:
				width=maxi(width,cell.x+1)
				height=maxi(height,cell.y+1)
			var masks: Array[int] = []
			masks.resize(height)
			masks.fill(0)
			for cell in piece.shape: masks[cell.y] |= 1 << cell.x
			shape_masks[key] = {"width":width,"height":height,"rows":masks}
		var shape: Dictionary = shape_masks[key]
		for y in range(9-shape.height):
			for x in range(9-shape.width):
				var origin := Vector2i(x,y)
				var legal := true
				for dy in shape.height:
					if (rows[y+dy] & (shape.rows[dy]<<x)) != 0:
						legal=false
						break
				if not legal: continue
				var after := rows.duplicate()
				for dy in shape.height: after[y+dy] |= shape.rows[dy]<<x
				var full_cols := 255
				var lines := 0
				for row in after:
					full_cols &= row
					if row==255: lines+=1
				lines+=popcount(full_cols)
				for ry in 8: after[ry] = 0 if after[ry]==255 else after[ry]&(~full_cols&255)
				var holes := 0
				for hy in 8:
					var left: int = ((after[hy]<<1)|1)&255
					var right: int = (after[hy]>>1)|128
					var top: int = 255 if hy==0 else after[hy-1]
					var bottom: int = 255 if hy==7 else after[hy+1]
					holes += popcount(((left&right&(top|bottom))|(top&bottom&(left|right)))&(~after[hy]&255))
				var value: float = lines*10000-holes*100-piece.shape.size()*0.01
				if value>best_value:
					best_value=value
					best={"slot":slot,"origin":origin}
	return best

static func popcount(value: int) -> int:
	value = value - ((value>>1)&0x55)
	value = (value&0x33)+((value>>2)&0x33)
	return (value+(value>>4))&0x0f

static func play(seed_value: int, limit: int = 2000) -> Dictionary:
	var session := GameSession.new(seed_value)
	var monotone := true
	var guarantee_failures := [0]
	var check_tray := func():
		var shapes: Array = []
		for piece in session.tray:
			if piece != null: shapes.append(piece.shape)
		if not session.board.has_any_move(shapes): guarantee_failures[0]+=1
	check_tray.call()
	session.tray_refilled.connect(check_tray)
	for i in limit:
		if session.state!="active": break
		var selected := move(session)
		if selected.slot<0:
			session.evaluate()
			break
		var before := session.score
		session.place(selected.slot,selected.origin)
		monotone = monotone and session.score>=before
	# Disconnect the capturing lambda to avoid a RefCounted cycle.
	session.tray_refilled.disconnect(check_tray)
	return {"seed":seed_value,"pieces":session.pieces,"score":session.score,"lines":session.lines,"finished":session.state=="finished","monotone":monotone,"guarantee_failures":guarantee_failures[0]}
