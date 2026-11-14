class_name BoardModel
extends RefCounted

const SIZE := 8
var cells: Array[Array] = []

func _init() -> void:
	clear()

func clear() -> void:
	cells.clear()
	for y in SIZE:
		var row: Array = []
		row.resize(SIZE)
		row.fill(-1)
		cells.append(row)

func can_place(shape: Array[Vector2i], origin: Vector2i) -> bool:
	if shape.is_empty(): return false
	var seen := {}
	for offset in shape:
		if seen.has(offset): return false
		seen[offset] = true
		var p := origin + offset
		if p.x < 0 or p.x >= SIZE or p.y < 0 or p.y >= SIZE or cells[p.y][p.x] != -1:
			return false
	return true

func place(shape: Array[Vector2i], origin: Vector2i, color: int) -> Dictionary:
	if not can_place(shape, origin):
		return {"valid": false, "rows": [], "cols": [], "cleared": [], "lines": 0}
	if color < 0 or color > 4:
		return {"valid": false, "rows": [], "cols": [], "cleared": [], "lines": 0}
	for offset in shape:
		var p := origin + offset
		cells[p.y][p.x] = color
	var cleared := clear_completed()
	return {"valid": true, "rows": cleared.rows, "cols": cleared.cols, "cleared": cleared.cells, "lines": cleared.rows.size() + cleared.cols.size()}

func clear_completed() -> Dictionary:
	var full_rows: Array[int] = []
	var full_cols: Array[int] = []
	for y in SIZE:
		var full := true
		for x in SIZE:
			if cells[y][x] == -1: full = false
		if full: full_rows.append(y)
	for x in SIZE:
		var full := true
		for y in SIZE:
			if cells[y][x] == -1: full = false
		if full: full_cols.append(x)
	var cleared: Array[Vector2i] = []
	for y in full_rows:
		for x in SIZE: cleared.append(Vector2i(x, y))
	for x in full_cols:
		for y in SIZE:
			var p := Vector2i(x, y)
			if not cleared.has(p): cleared.append(p)
	for p in cleared: cells[p.y][p.x] = -1
	return {"rows": full_rows, "cols": full_cols, "cells": cleared}

func occupancy() -> float:
	var occupied := 0
	for row in cells:
		for cell in row:
			if cell != -1: occupied += 1
	return occupied / float(SIZE * SIZE)

func is_empty() -> bool:
	return occupancy() == 0.0

func has_any_move(shapes: Array) -> bool:
	for shape in shapes:
		var typed_shape: Array[Vector2i] = []
		for raw_cell in shape:
			typed_shape.append(Vector2i(raw_cell))
		for y in SIZE:
			for x in SIZE:
				if can_place(typed_shape, Vector2i(x, y)): return true
	return false

func to_dict() -> Dictionary:
	return {"cells": cells.duplicate(true)}

func from_dict(data: Dictionary) -> void:
	clear()
	if data.get("cells") is Array:
		for y in min(SIZE, data.cells.size()):
			if not data.cells[y] is Array: continue
			for x in min(SIZE, data.cells[y].size()):
				var value: Variant = data.cells[y][x]
				if value is int or value is float:
					cells[y][x] = clampi(int(value), -1, 4)
