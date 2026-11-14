extends RefCounted

func run(t) -> void:
	var board := BoardModel.new()
	var rng := SeededRng.new(42)
	var origin := Vector2(24,136)
	for id in ["mono","i5_v","sq3"]:
		var shape := PieceCatalog.shape_for(id)
		var bbox := Vector2i.ONE
		for cell in shape: bbox = Vector2i(maxi(bbox.x,cell.x+1),maxi(bbox.y,cell.y+1))
		for i in 1000:
			var pointer := Vector2(rng.next_float()*390,rng.next_float()*844)
			var preview := DropResolver.resolve(pointer,shape,bbox,40,origin,board)
			t.check_eq(preview,DropResolver.resolve(pointer,shape,bbox,40,origin,board),"preview/release equality")
			t.check(preview.visual_top_left.x>=0 and preview.visual_top_left.y>=0,"viewport clamp")
	var pointer := origin+Vector2(20,76)
	var exact := DropResolver.resolve(pointer,[Vector2i.ZERO],Vector2i.ONE,40,origin,board,false)
	t.check_eq(exact.origin,Vector2i.ZERO,"exact alignment")
	for delta in [-0.3,0.3]:
		var jitter := DropResolver.resolve(pointer+Vector2.ONE*delta*40,[Vector2i.ZERO],Vector2i.ONE,40,origin,board,false,Vector2i.ZERO)
		t.check_eq(jitter.origin,Vector2i.ZERO,"hysteresis")
	board.cells[0][0]=0
	var assisted := DropResolver.resolve(pointer+Vector2(20,0),[Vector2i.ZERO],Vector2i.ONE,40,origin,board,true,Vector2i.ZERO)
	t.check_eq(assisted.origin,Vector2i(1,0),"assist chooses legal neighbor")
	board.cells[1][1]=0
	var tied := DropResolver.resolve(pointer+Vector2.ONE*24,[Vector2i.ZERO],Vector2i.ONE,40,origin,board,true,Vector2i.ZERO)
	t.check_eq(tied.origin,Vector2i(1,0),"assist equal-distance tie uses smaller y")
	var offboard := DropResolver.resolve(Vector2(200,800),[Vector2i.ZERO],Vector2i.ONE,40,origin,board,false)
	t.check(not offboard.valid and not offboard.over_board,"offboard rejected")
