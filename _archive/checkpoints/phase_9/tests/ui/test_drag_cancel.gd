extends RefCounted

const DragTools = preload("res://tests/ui/drag_test_tools.gd")

func run(t) -> void:
	var root=DragTools.fixture(t)
	var game: GameScreen=root.router.current
	var drag:=game.drag
	var snapshot: Dictionary=root.session.to_dict()
	for notification in [Node.NOTIFICATION_APPLICATION_FOCUS_OUT,Node.NOTIFICATION_APPLICATION_PAUSED,Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		drag.lock_until_ms=0
		DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
		drag.notification(notification)
		t.check_eq(drag.owner_index,-1,"notification cancels owner")
		t.check_eq(root.session.board.cells,snapshot.board,"cancel leaves board unchanged")
		t.check_eq(root.session.score,snapshot.score,"cancel leaves score unchanged")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	drag.last_event_ms=Time.get_ticks_msec()-2001
	drag._process(0)
	t.check_eq(drag.owner_index,-1,"lost touch timeout")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	DragTools.motion(drag,Vector2(200,800))
	DragTools.touch(drag,Vector2(200,800),false)
	t.check_eq(root.session.pieces,0,"outside release doesn't place")
	t.check(root.session.tray[0]!=null,"invalid drop retains piece")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	game._layout()
	t.check_eq(drag.owner_index,-1,"resize/layout cancels drag")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	DragTools.touch(drag,game.metrics.slots[0].get_center(),false,0,true)
	t.check_eq(drag.owner_index,-1,"system-cancelled touch returns piece")
	drag.lock_until_ms=0
	DragTools.touch(drag,game.metrics.slots[0].get_center(),true)
	root.pause_game()
	t.check_eq(drag.owner_index,-1,"modal opening cancels drag")
	t.check(drag.modal_open,"modal blocks new drags")
	root.router.pop_modal()
	root.queue_free()
	await t.get_tree().process_frame
