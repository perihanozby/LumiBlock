extends RefCounted

func run(t) -> void:
	var root=DragTestTools.fixture(t)
	var game: GameScreen=root.router.current
	var drag:=game.drag
	DragTestTools.touch(drag,game.metrics.slots[0].get_center(),true,4)
	t.check_eq(drag.owner_index,4,"first pointer owns drag")
	DragTestTools.touch(drag,game.metrics.slots[1].get_center(),true,7)
	DragTestTools.motion(drag,DragTestTools.target(game,0,Vector2i.ZERO),7)
	DragTestTools.touch(drag,DragTestTools.target(game,0,Vector2i.ZERO),false,7)
	t.check_eq(root.session.pieces,0,"second finger cannot drop")
	t.check_eq(drag.owner_index,4,"second finger cannot take ownership")
	var target:=DragTestTools.target(game,0,Vector2i.ZERO)
	DragTestTools.motion(drag,target,4)
	var ghost: Vector2i=game.board_view.ghost.origin
	DragTestTools.touch(drag,target,false,4)
	t.check_eq(root.session.pieces,1,"owner release places once")
	t.check_eq(root.session.board.cells[ghost.y][ghost.x],0,"placed cell equals ghost cell")
	t.check(root.session.tray[0]==null and root.session.tray[1].color==1,"fixed slots")
	drag.lock_until_ms=0
	DragTestTools.touch(drag,game.metrics.slots[0].get_center(),true)
	t.check_eq(drag.owner_index,-1,"empty slot never captured")
	root.queue_free()
	await t.get_tree().process_frame
