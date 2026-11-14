extends RefCounted

func run(t) -> void:
	var root=MenuTestTools.fixture(t)
	root.start_game("classic",true)
	root.router.settle_transition()
	root.session.score=1234
	root.session.lines=7
	root.session.pieces=20
	root.session.finish("over")
	root.session_changed()
	var over: MenuScreen=root.router.modals[-1]
	t.check_eq(over.labels["over.score"].text,"1,234","result score matches session")
	t.check_eq(over.labels["over.lines.value"].text,"7","result lines match")
	t.check_eq(SaveService.profile.stats.games_finished,1,"stats committed before modal")
	t.check(not over.labels.has("over.new_best"),"no record badge when prior record was zero")
	root.best_before=500
	over.rebuild()
	t.check(over.labels.has("over.new_best"),"record badge when positive prior best exceeded")
	root.session_changed()
	t.check_eq(SaveService.profile.stats.games_finished,1,"reopening doesn't recount")
	root.router.back()
	root.router.settle_transition()
	t.check_eq(root.router.current_id,"home","back from game-over returns Home")
	root.router.go("game",{"session":root.session})
	root.router.settle_transition()
	root.router.push_modal(root.scene("game_over"))
	MenuTestTools.click(t,root,"over.again")
	t.check_eq(root.session.state,"active","again starts new game")
	root.session.finish("over")
	root.session_changed()
	MenuTestTools.click(t,root,"over.menu")
	t.check_eq(root.router.current_id,"home","result menu")
	root.start_game("daily",true)
	root.router.settle_transition()
	var mission:=DailyChallenge.describe(root.today())
	if mission.template==0: root.session.lines=mission.target
	elif mission.template==1: root.session.score=mission.target
	else: root.session.max_combo=mission.target
	root.session.evaluate()
	root.session_changed()
	t.check(root.router.modals[-1].labels.has("over.daily.done"),"daily completion result")
	t.check_eq(SaveService.profile.stats.daily_completed,1,"daily committed")
	MenuTestTools.click(t,root,"daily.replay")
	root.session.finish("failed")
	root.session_changed()
	t.check(root.router.modals[-1].labels.has("over.daily.failed"),"daily failed result")
	MenuTestTools.click(t,root,"over.retry")
	t.check_eq(root.session.state,"active","daily retry active")
	root.queue_free()
	await t.get_tree().process_frame
