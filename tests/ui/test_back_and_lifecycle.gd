extends RefCounted

const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=MenuTools.fixture(t)
	var quit_count:=[0]
	root.quit_hook=func(): quit_count[0]+=1
	root.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	t.check_eq(quit_count[0],1,"Home back requests real quit path")
	root.start_game("classic",true)
	root.router.settle_transition()
	root.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	t.check_eq(root.router.modals.size(),1,"Game back pauses")
	root.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	t.check_eq(root.router.modals.size(),0,"Pause back resumes")
	root.session.score=777
	root.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	t.check_eq(root.router.modals.size(),1,"application pause opens pause")
	var saved:=SaveService.load_game()
	t.check_eq(saved.sessions.classic.score,777,"lifecycle flushes latest score")
	root.queue_free()
	await t.get_tree().process_frame
