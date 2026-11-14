extends RefCounted

const DragTools = preload("res://tests/ui/drag_test_tools.gd")

func run(t) -> void:
	var root=DragTools.fixture(t)
	var game: GameScreen=root.router.current
	var drag:=game.drag
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true,4)
	t.check_eq(drag.owner_index,4,"first pointer owns drag")
	DragTools.touch(drag,game.metrics.slots[1].get_center(),true,7)
	DragTools.motion(drag,DragTools.target(game,0,Vector2i.ZERO),7)
	DragTools.touch(drag,DragTools.target(game,0,Vector2i.ZERO),false,7)
	t.check_eq(root.session.pieces,0,"second finger cannot drop")
	t.check_eq(drag.owner_index,4,"second finger cannot take ownership")
	var target:=DragTools.target(game,0,Vector2i.ZERO)
	DragTools.motion(drag,target,4)
	var ghost: Vector2i=game.board_view.ghost.origin
	DragTools.touch(drag,target,false,4)
	t.check_eq(root.session.pieces,1,"owner release places once")
	t.check_eq(root.session.board.cells[ghost.y][ghost.x],0,"placed cell equals ghost cell")
	t.check(root.session.tray[0]==null and root.session.tray[1].color==1,"fixed slots")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	t.check_eq(drag.owner_index,-1,"empty slot never captured")
	root.queue_free()
	await t.get_tree().process_frame
