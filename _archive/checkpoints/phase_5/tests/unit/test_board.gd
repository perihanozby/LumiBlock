extends RefCounted

func run(t) -> void:
	var board := BoardModel.new()
	var mono: Array[Vector2i] = [Vector2i.ZERO]
	var snapshot := board.to_dict()
	t.check(not board.place(mono, Vector2i(8, 8), 0).valid, "out of bounds rejected")
	t.check_eq(board.to_dict(), snapshot, "invalid placement atomic")
	t.check(not board.can_place([], Vector2i.ZERO), "empty shape rejected")
	t.check(board.place(mono, Vector2i.ZERO, 4).valid, "fifth family accepted")
	t.check_eq(snapshot.cells[0][0], -1, "snapshot independent")
	t.check(not board.place(mono, Vector2i.ZERO, 1).valid, "overlap rejected")
	t.check_eq(board.occupancy(), 1.0 / 64.0, "occupancy")

