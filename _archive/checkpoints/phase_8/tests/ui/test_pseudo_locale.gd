extends RefCounted

const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=MenuTools.fixture(t)
	LocalizationService.apply_language("en_XA")
	t.check_eq(LocalizationService.locale,"en_XA","debug pseudo locale applies")
	t.check(root.tr("home.play").begins_with("["),"pseudo strings are registered")
	t.check(root.tr("home.tagline").length()>50,"pseudo expands source by at least 40 percent")
	for id in ["home","settings","stats"]:
		root.show_screen(id)
		root.router.settle_transition()
		await t.get_tree().process_frame
		walk(t,root.router.current,root.get_viewport_rect())
	LocalizationService.apply_language("en")
	root.queue_free()
	await t.get_tree().process_frame

func walk(t,node: Node,viewport: Rect2) -> void:
	if node is LBButton and node.visible: t.check(node.get_global_rect().end.x<=viewport.end.x+1,"pseudo button fits horizontal viewport")
	for child in node.get_children(): walk(t,child,viewport)
