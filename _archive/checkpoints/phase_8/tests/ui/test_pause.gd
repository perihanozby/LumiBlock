extends RefCounted

const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=MenuTools.fixture(t)
	root.start_game("classic",true)
	root.router.settle_transition()
	root.pause_game()
	var elapsed: float=root.session.elapsed_s
	await t.get_tree().create_timer(0.1).timeout
	t.check_eq(root.session.elapsed_s,elapsed,"pause freezes elapsed")
	MenuTools.click(t,root,"pause.settings")
	t.check_eq(root.router.modals.size(),2,"settings overlays pause")
	root.router.back()
	MenuTools.click(t,root,"pause.restart")
	t.check(root.router.modals[-1] is LBDialog,"restart asks confirmation")
	root.router.back()
	t.check_eq(SaveService.profile.stats.games_abandoned,0,"cancel restart preserves game")
	MenuTools.click(t,root,"pause.restart")
	MenuTools.click(t,root,"common.confirm")
	t.check_eq(SaveService.profile.stats.games_abandoned,1,"confirmed restart abandons once")
	root.pause_game()
	MenuTools.click(t,root,"pause.resume")
	t.check(root.router.modals.is_empty(),"resume closes pause")
	root.pause_game()
	MenuTools.click(t,root,"pause.menu")
	t.check_eq(root.router.current_id,"home","menu saves and returns home")
	t.check(root.resumable("classic"),"menu keeps session")
	root.queue_free()
	await t.get_tree().process_frame
