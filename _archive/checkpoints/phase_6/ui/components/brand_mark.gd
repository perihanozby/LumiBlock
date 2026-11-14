class_name BrandMark
extends Control

func _ready() -> void:
	custom_minimum_size=Vector2(72,88)
	mouse_filter=Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var texture:=PieceView.texture()
	var cells: Array[Vector2i]=[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2)]
	for i in cells.size():
		draw_texture_rect_region(texture,Rect2(Vector2(cells[i])*28,Vector2.ONE*28),Rect2(0,i*128,128,128))
