class_name PieceView
extends Control

static var atlas: Texture2D
var piece: PieceModel
var pitch:=32.0
var marked:=false
var atlas_column:=0

static func texture() -> Texture2D:
	if atlas==null: atlas=load("res://assets/cubes/cube_atlas.png")
	return atlas

static func bounds(cells: Array[Vector2i]) -> Vector2i:
	var bbox:=Vector2i.ONE
	for cell in cells: bbox=Vector2i(maxi(bbox.x,cell.x+1),maxi(bbox.y,cell.y+1))
	return bbox

func configure(value: PieceModel, cell_pitch: float, marks: bool = false) -> void:
	piece=value
	pitch=cell_pitch
	marked=marks
	queue_redraw()

func _draw() -> void:
	if piece==null: return
	var source:=Rect2((1 if marked else atlas_column)*128,piece.color*128,128,128)
	for cell in piece.shape: draw_texture_rect_region(texture(),Rect2(Vector2(cell)*pitch,Vector2.ONE*pitch),source)
