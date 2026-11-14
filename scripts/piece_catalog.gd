class_name PieceCatalog
extends RefCounted

const PieceModelScript = preload("res://scripts/piece_model.gd")

const SHAPES: Array = [
	[Vector2i(0, 0)], [Vector2i(0, 0), Vector2i(1, 0)],
	[Vector2i(0, 0), Vector2i(0, 1)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
]

static func normalized(shape: Array[Vector2i]) -> Array[Vector2i]:
	var min_x := 999
	var min_y := 999
	for p in shape: min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
	var result: Array[Vector2i] = []
	for p in shape:
		var normalized_cell := Vector2i(p.x - min_x, p.y - min_y)
		if not result.has(normalized_cell): result.append(normalized_cell)
	result.sort_custom(func(a: Vector2i, b: Vector2i): return a.y * 10 + a.x < b.y * 10 + b.x)
	return result

static func is_valid_shape(shape: Array[Vector2i]) -> bool:
	if shape.is_empty() or shape.size() > 9: return false
	var unique: Dictionary = {}
	for cell in shape:
		if unique.has(cell): return false
		unique[cell] = true
	var visited: Array[Vector2i] = [shape[0]]
	var pending: Array[Vector2i] = [shape[0]]
	while not pending.is_empty():
		var current: Vector2i = pending.pop_back()
		for neighbor in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = current + neighbor
			if shape.has(next) and not visited.has(next):
				visited.append(next); pending.append(next)
	return visited.size() == shape.size()

static func generate(rng: RandomNumberGenerator, count: int = 3) -> Array[PieceModel]:
	var tray: Array[PieceModel] = []
	for i in count:
		var raw_shape: Array = SHAPES[rng.randi_range(0, SHAPES.size() - 1)]
		var typed_shape: Array[Vector2i] = []
		for raw_cell in raw_shape:
			typed_shape.append(Vector2i(raw_cell))
		var normalized_shape := normalized(typed_shape)
		if is_valid_shape(normalized_shape): tray.append(PieceModelScript.new(normalized_shape, rng.randi_range(0, 3)))
	if tray.size() < count:
		return generate(rng, count)
	return tray

static func entries() -> Dictionary:
	var catalog := {}
	var seeds := {
		"mono": [Vector2i(0,0)], "dom": [Vector2i(0,0),Vector2i(1,0)],
		"i3": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)],
		"l3": [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)],
		"i4": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)],
		"o4": [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)],
		"t4": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(1,1)],
		"l4": [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2)],
		"j4": [Vector2i(1,0),Vector2i(1,1),Vector2i(1,2),Vector2i(0,2)],
		"s4": [Vector2i(1,0),Vector2i(2,0),Vector2i(0,1),Vector2i(1,1)],
		"z4": [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(2,1)],
		"i5": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0)],
		"v5": [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2),Vector2i(2,2)],
		"r23": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(0,1),Vector2i(1,1),Vector2i(2,1)],
		"sq3": [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(0,2),Vector2i(1,2),Vector2i(2,2)]}
	for family in seeds:
		var count := 4 if family in ["l3", "t4", "l4", "j4", "v5"] else (1 if family in ["mono", "o4", "sq3"] else 2)
		var shape: Array[Vector2i] = []
		shape.assign(seeds[family])
		for orientation in count:
			var id: String = family if count == 1 else (family + "_" + str(orientation) if count == 4 else family + ("_h" if orientation == 0 else "_v"))
			catalog[id] = normalized(shape)
			var rotated: Array[Vector2i] = []
			for cell in shape: rotated.append(Vector2i(-cell.y, cell.x))
			shape = rotated
	return catalog

static func shape_for(id: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(entries().get(id, []))
	return result

static func id_for(shape: Array[Vector2i]) -> String:
	var norm := normalized(shape)
	var all := entries()
	for id in all:
		if all[id] == norm: return id
	return ""
