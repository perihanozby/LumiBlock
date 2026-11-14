class_name DragLayer
extends Control

var piece: PieceModel
var top_left:=Vector2.ZERO
var pitch:=40.0
var lift_progress:=1.0:
	set(value):
		lift_progress=value
		queue_redraw()
var rest_position:=Vector2.ZERO
var rest_pitch:=24.0
var animation: Tween

func begin_lift(position_rest: Vector2,pitch_rest: float) -> void:
	stop_animation()
	rest_position=position_rest-global_position
	rest_pitch=pitch_rest
	lift_progress=1 if SettingsService.reduce_motion() else 0
	if not SettingsService.reduce_motion():
		animation=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		animation.tween_property(self,"lift_progress",1.0,0.09)

func stop_animation() -> void:
	if animation!=null: animation.kill()

func return_to_slot(position_rest: Vector2,pitch_rest: float,finished: Callable) -> void:
	stop_animation()
	if SettingsService.reduce_motion() or piece==null:
		piece=null
		finished.call()
		queue_redraw()
		return
	animation=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	animation.tween_property(self,"top_left",position_rest-global_position,0.14)
	animation.tween_property(self,"pitch",pitch_rest,0.14)
	animation.tween_method(func(_value): queue_redraw(),0.0,1.0,0.14)
	animation.finished.connect(func(): piece=null; queue_redraw(); finished.call())

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	layout_direction=Control.LAYOUT_DIRECTION_LTR

func update_piece(value: PieceModel,info: Dictionary,cell_pitch: float) -> void:
	piece=value
	if value==null: stop_animation()
	if not info.is_empty(): top_left=info.visual_top_left-global_position
	pitch=cell_pitch
	queue_redraw()

func _draw() -> void:
	if piece==null: return
	var texture:=PieceView.texture()
	var draw_pitch:=lerpf(rest_pitch,pitch,lift_progress)
	var position:=rest_position.lerp(top_left,lift_progress)
	var extent:=Vector2(PieceView.bounds(piece.shape))*draw_pitch
	draw_texture_rect_region(texture,Rect2(position+Vector2(0,10)-extent*0.075,extent*1.15),Rect2(384,640,128,128),Color(0,0,0,0.45*lift_progress))
	for cell in piece.shape:
		draw_texture_rect_region(texture,Rect2(position+Vector2(cell)*draw_pitch,Vector2.ONE*draw_pitch),Rect2(256,piece.color*128,128,128))
