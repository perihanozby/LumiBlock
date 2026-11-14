class_name TrayView
extends Control

var session: GameSession
var slots: Array[Rect2]=[]
var lifted_slot:=-1
var marked:=false

func _ready() -> void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR
	mouse_filter=Control.MOUSE_FILTER_IGNORE

func configure(value: GameSession,rects: Array[Rect2],marks: bool = false) -> void:
	session=value
	slots=rects
	marked=marks
	queue_redraw()

func slot_at(viewport_position: Vector2) -> int:
	for i in slots.size():
		if slots[i].grow(8).has_point(viewport_position): return i
	return -1

func _draw() -> void:
	if session==null: return
	var texture:=PieceView.texture()
	for i in slots.size():
		var rect:=Rect2(slots[i].position-global_position,slots[i].size)
		draw_rect(rect,Tokens.SURFACE.darkened(0.1))
		if session.tray[i]==null or i==lifted_slot:
			draw_rect(rect.grow(-8),Tokens.HAIRLINE,false,1)
			continue
		var piece:=session.tray[i]
		var bbox:=PieceView.bounds(piece.shape)
		var cell_pitch:=minf(rect.size.x/(bbox.x+1),minf(rect.size.y/(bbox.y+1),32))
		var origin:=rect.get_center()-Vector2(bbox)*cell_pitch/2
		for cell in piece.shape:
			draw_texture_rect_region(texture,Rect2(origin+Vector2(cell)*cell_pitch,Vector2.ONE*cell_pitch),Rect2(128 if marked else 0,piece.color*128,128,128))
