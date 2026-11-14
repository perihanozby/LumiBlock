class_name DragTestTools
extends RefCounted

static func touch(controller: DragController,position: Vector2,pressed: bool,index: int = 0,canceled: bool = false) -> void:
	var event:=InputEventScreenTouch.new()
	event.position=controller.get_viewport().get_canvas_transform()*position
	event.pressed=pressed
	event.index=index
	event.canceled=canceled
	controller.handle(event)

static func motion(controller: DragController,position: Vector2,index: int = 0) -> void:
	var event:=InputEventScreenDrag.new()
	event.position=controller.get_viewport().get_canvas_transform()*position
	event.index=index
	controller.handle(event)

static func target(game: GameScreen,slot: int,origin: Vector2i) -> Vector2:
	var bbox:=PieceView.bounds(game.session.tray[slot].shape)
	return game.metrics.board_origin+Vector2(origin)*game.metrics.pitch+Vector2(bbox.x*game.metrics.pitch/2,(bbox.y+0.9)*game.metrics.pitch)

static func fixture(t):
	var root=load("res://app/app_root.tscn").instantiate()
	t.add_child(root)
	root.session=GameSession.new(23)
	root.session.tray.assign([PieceGenerator.make_piece("mono",0),PieceGenerator.make_piece("mono",1),PieceGenerator.make_piece("mono",2)])
	root.router.go("game",{"session":root.session})
	root.router.settle_transition()
	return root
