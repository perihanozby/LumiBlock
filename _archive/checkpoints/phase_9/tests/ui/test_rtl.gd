extends RefCounted

const DragTools = preload("res://tests/ui/drag_test_tools.gd")
const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=DragTools.fixture(t)
	var game: GameScreen=root.router.current
	var board_position:=game.board_view.global_position
	var slots: Array=game.metrics.slots.duplicate()
	LocalizationService.apply_language("ar")
	t.check_eq(game.board_view.layout_direction,Control.LAYOUT_DIRECTION_LTR,"Arabic board stays LTR")
	t.check_eq(game.tray_view.layout_direction,Control.LAYOUT_DIRECTION_LTR,"Arabic tray stays LTR")
	t.check_eq(game.drag_layer.layout_direction,Control.LAYOUT_DIRECTION_LTR,"Arabic drag stays LTR")
	t.check_eq(game.score_label.layout_direction,Control.LAYOUT_DIRECTION_LTR,"Western score digit cells stay LTR")
	t.check_eq(game.board_view.global_position,board_position,"board geometry unchanged in RTL")
	t.check_eq(game.metrics.slots,slots,"tray slot geometry unchanged in RTL")
	t.check_eq(game.caption_label.text,root.tr("game.score"),"live HUD caption relabels")
	root.show_screen("about")
	root.router.settle_transition()
	var back:=MenuTools.find_button(root.router.current,"common.back")
	t.check(back.mirrored,"Arabic back arrow artwork mirrors")
	LocalizationService.apply_language("en")
	root.queue_free()
	await t.get_tree().process_frame
