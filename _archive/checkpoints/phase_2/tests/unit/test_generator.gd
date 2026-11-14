extends RefCounted

func run(t) -> void:
	var rng := SeededRng.new(70)
	for i in 5000:
		var board := BoardModel.new()
		for y in 8:
			for x in 8:
				if rng.next_float()<0.7: board.cells[y][x]=rng.range_int(0,4)
		board.cells[0][0] = -1
		var tray := PieceGenerator.next_tray(board,rng,{"pieces":20})
		t.check(board.has_any_move([tray[0].shape,tray[1].shape,tray[2].shape]),"first-level guarantee")
		t.check(not (tray[0].shape_id==tray[1].shape_id and tray[1].shape_id==tray[2].shape_id),"no triple shape")
		t.check(not (tray[0].color==tray[1].color and tray[1].color==tray[2].color),"no triple colour")
	var counts := [0,0,0,0,0,0]
	var empty := BoardModel.new()
	for i in 20000:
		var piece := PieceGenerator.next_piece(empty,rng,{"pieces":20})
		counts[mini(piece.shape.size(),6)-1] += 1
	for i in 6: t.check(absf(counts[i]/200.0-[4,12,24,30,20,10][i])<=3,"distribution bucket " + str(i))
	for i in 1000:
		var piece := PieceGenerator.next_piece(empty,rng,{"pieces":i%10})
		t.check(piece.shape.size()<6,"opening excludes >=6 cells")
