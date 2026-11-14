extends RefCounted

func run(t) -> void:
	var root=DragTestTools.fixture(t)
	var game: GameScreen=root.router.current
	SettingsService.set_value("reduce_motion",true)
	var piece:=PieceGenerator.make_piece("mono",0)
	game.fx.placement(piece,Vector2i.ZERO,{"lines":2,"cleared":[Vector2i.ZERO,Vector2i.ONE]},game.metrics)
	t.check(game.fx.reduced,"FX uses reduce-motion branch")
	t.check_eq(game.fx.sparks.size(),0,"zero particles under reduce motion")
	t.check_eq(game.fx.tweens.size(),0,"zero position or scale tweens under reduce motion")
	game.fx.cancel_all()
	t.check(game.fx.effects.is_empty(),"modal/screen cancellation clears FX")
	SettingsService.set_value("reduce_motion",false)
	SettingsService.set_value("effects","rich")
	game.fx.placement(piece,Vector2i.ZERO,{"lines":2,"cleared":[Vector2i.ZERO,Vector2i.ONE]},game.metrics)
	t.check_eq(game.fx.sparks.size(),20,"rich level emits 10 sparks per line")
	game.fx.cancel_all()
	SettingsService.set_value("effects","minimal")
	game.fx.placement(piece,Vector2i.ZERO,{"lines":2,"cleared":[Vector2i.ZERO]},game.metrics)
	t.check_eq(game.fx.sparks.size(),0,"minimal emits no particles")
	root.queue_free()
	await t.get_tree().process_frame
