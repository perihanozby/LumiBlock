extends RefCounted

func run(t) -> void:
	var sound_before: bool=SettingsService.values.sfx
	SettingsService.set_value("sfx",false)
	var root=DragTestTools.fixture(t)
	var game: GameScreen=root.router.current
	var moves:=0
	var games:=1
	while moves<200:
		if root.session.state=="finished":
			root.start_game("classic",true)
			root.router.settle_transition()
			game=root.router.current
			games+=1
		var selected:=GreedyBot.move(root.session)
		t.check(selected.slot>=0,"bot legal move")
		if selected.slot<0: break
		game.drag.lock_until_ms=0
		var target:=DragTestTools.target(game,selected.slot,selected.origin)
		var old_score: int=root.session.score
		DragTestTools.touch(game.drag,game.metrics.slots[selected.slot].get_center(),true)
		DragTestTools.motion(game.drag,target)
		var ghost: Vector2i=game.board_view.ghost.origin
		t.check_eq(ghost,selected.origin,"fast flick preview origin")
		DragTestTools.touch(game.drag,target,false)
		t.check(root.session.score>old_score,"UI bot move changes score")
		t.check_eq(game.score_label.value,root.session.score,"HUD signal matches model")
		moves+=1
		if moves%25==0: await t.get_tree().process_frame
	t.check_eq(moves,200,"200 moves through real drag controller")
	t.check(games>1,"UI bot reached game over and restarted")
	print("UI bot: %d moves, %d games" % [moves,games])
	SettingsService.set_value("sfx",sound_before)
	root.queue_free()
	await t.get_tree().process_frame
