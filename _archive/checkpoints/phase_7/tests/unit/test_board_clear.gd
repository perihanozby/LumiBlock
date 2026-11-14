extends RefCounted

func run(t) -> void:
	for dimensions in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(8, 0)]:
		var board := BoardModel.new()
		for y in dimensions.x:
			for x in 8: board.cells[y][x] = 0
		for x in dimensions.y:
			for y in 8: board.cells[y][x] = 1
		var result := board.clear_completed()
		# Filling all rows also fills all columns: 16 lines, 64 unique cells.
		var expected_lines: int = 16 if dimensions.x == 8 else dimensions.x + dimensions.y
		t.check_eq(result.rows.size() + result.cols.size(), expected_lines, "simultaneous line count " + str(dimensions))
		t.check_eq(result.cells.size(), dimensions.x * 8 + dimensions.y * 8 - dimensions.x * dimensions.y, "deduplicated cells")
		t.check(board.is_empty(), "clear empties constructed board")
	var cross := BoardModel.new()
	for i in 8:
		cross.cells[0][i] = 0
		cross.cells[i][0] = 0
	cross.cells[0][0] = -1
	var placed := cross.place([Vector2i.ZERO], Vector2i.ZERO, 0)
	t.check_eq(placed.lines, 2, "placement returns 2 cross lines")
	t.check_eq(placed.cleared.size(), 15, "placement keeps cleared compatibility key")
