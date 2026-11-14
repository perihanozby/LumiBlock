class_name DragLayer
extends Control

var piece: PieceModel
var top_left:=Vector2.ZERO
var pitch:=40.0

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	layout_direction=Control.LAYOUT_DIRECTION_LTR

func update_piece(value: PieceModel,info: Dictionary,cell_pitch: float) -> void:
	piece=value
	if not info.is_empty(): top_left=info.visual_top_left-global_position
	pitch=cell_pitch
	queue_redraw()

func _draw() -> void:
	if piece==null: return
	var texture:=PieceView.texture()
	var extent:=Vector2(PieceView.bounds(piece.shape))*pitch
	draw_texture_rect_region(texture,Rect2(top_left+Vector2(0,10)-extent*0.075,extent*1.15),Rect2(384,640,128,128),Color(0,0,0,0.45))
	for cell in piece.shape:
		draw_texture_rect_region(texture,Rect2(top_left+Vector2(cell)*pitch,Vector2.ONE*pitch),Rect2(256,piece.color*128,128,128))
