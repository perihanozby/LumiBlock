class_name BrandMark
extends Control
var age:=0.0

func _ready() -> void:
	custom_minimum_size=Vector2(72,88)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	SettingsService.changed.connect(func(_key,_value): _motion_mode())
	_motion_mode()

func _motion_mode() -> void:
	set_process(not SettingsService.reduce_motion() and SettingsService.values.effects!="minimal")
	queue_redraw()

func _process(delta: float) -> void:
	age+=delta
	queue_redraw()

func _draw() -> void:
	var texture:=PieceView.texture()
	var opacity:=0.055 if not is_processing() else 0.055+0.015*sin(TAU*age/6)
	draw_texture_rect_region(texture,Rect2(-40,-24,160,160),Rect2(384,640,128,128),Color(Tokens.PRIMARY,opacity))
	var cells: Array[Vector2i]=[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2)]
	for i in cells.size():
		draw_texture_rect_region(texture,Rect2(Vector2(cells[i])*28,Vector2.ONE*28),Rect2(0,i*128,128,128))
