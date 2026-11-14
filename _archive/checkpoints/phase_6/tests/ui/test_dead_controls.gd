extends RefCounted

func walk(t,node: Node) -> void:
	if node is LBButton: t.check(not node.pressed_action.get_connections().is_empty(),"action connected "+str(node.name))
	elif node is CheckButton: t.check(not node.toggled.get_connections().is_empty(),"toggle connected")
	elif node is HSlider: t.check(not node.value_changed.get_connections().is_empty(),"slider connected")
	for child in node.get_children(): walk(t,child)

func run(t) -> void:
	var root=MenuTestTools.fixture(t)
	for id in ["home","daily","stats","settings","about","privacy"]:
		root.show_screen(id)
		root.router.settle_transition()
		walk(t,root.router.current)
	root.start_game("classic",true)
	root.router.settle_transition()
	walk(t,root.router.current)
	root.pause_game()
	walk(t,root.router.modals[-1])
	root.queue_free()
	await t.get_tree().process_frame
