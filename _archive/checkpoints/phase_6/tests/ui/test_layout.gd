extends RefCounted

func walk(t,node: Node,viewport: Rect2) -> void:
	if node is LBButton and node.visible:
		t.check(node.size.x>=48 and node.size.y>=48,"touch target "+str(node.name))
		t.check(node.get_global_rect().position.x>=viewport.position.x-1 and node.get_global_rect().end.x<=viewport.end.x+1,"button inside horizontal viewport "+str(node.name))
	if node is Label and node.visible:
		t.check(node.get_theme_font_size("font_size")>=12,"minimum type size")
		t.check(node.get_global_rect().position.x>=viewport.position.x-1 and node.get_global_rect().end.x<=viewport.end.x+1,"label inside horizontal viewport")
	for child in node.get_children(): walk(t,child,viewport)

func run(t) -> void:
	var window: Window=t.get_window()
	var original: Vector2i=window.size
	var root=MenuTestTools.fixture(t)
	for size in [Vector2i(360,640),Vector2i(360,780),Vector2i(390,844),Vector2i(412,915),Vector2i(430,932),Vector2i(480,1000),Vector2i(600,1024)]:
		window.size=size
		await t.get_tree().process_frame
		for id in ["home","settings","stats"]:
			root.show_screen(id)
			root.router.settle_transition()
			await t.get_tree().process_frame
			walk(t,root.router.current,root.get_viewport_rect())
		root.start_game("classic",true)
		root.router.settle_transition()
		var game: GameScreen=root.router.current
		game._layout()
		t.check_eq(game.metrics.board_rect.size.x,game.metrics.board_rect.size.y,"actual board square")
		game.safe.injected_area=Rect2(Vector2(0,32),game.get_viewport_rect().size-Vector2(0,56))
		game._layout()
		t.check(game.metrics.board_rect.position.y>=32,"board outside injected cutout")
	root.queue_free()
	window.size=original
	await t.get_tree().process_frame
