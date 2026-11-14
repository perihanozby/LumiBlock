extends RefCounted

func run(t) -> void:
	var root=MenuTestTools.fixture(t)
	root.show_tutorial(true)
	root.router.settle_transition()
	var tutorial: GameScreen=root.router.current
	var started: int=SaveService.profile.stats.games_started
	var target:=DragTestTools.target(tutorial,0,Vector2i(0,7))
	DragTestTools.touch(tutorial.drag,tutorial.metrics.slots[0].get_center(),true)
	DragTestTools.motion(tutorial.drag,target)
	DragTestTools.touch(tutorial.drag,target,false)
	t.check_eq(tutorial.step,1,"real drag completes tutorial clear")
	tutorial.next_button.pressed.emit()
	t.check_eq(tutorial.step,2,"next advances explanation")
	tutorial.next_button.pressed.emit()
	root.router.settle_transition()
	t.check(SaveService.profile.flags.tutorial_done,"tutorial completion flag")
	t.check_eq(SaveService.profile.stats.games_started,started,"settings tutorial has no game stat impact")
	t.check_eq(root.router.current_id,"settings","settings tutorial returns to settings")
	root.queue_free()
	await t.get_tree().process_frame
