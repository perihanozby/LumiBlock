class_name BoardView
extends Control

var board: BoardModel
var pitch:=40.0
var marked:=false
var ghost: Dictionary={}
var ghost_piece: PieceModel
var redraw_requests:=0
var last_draw_us:=0
var draw_count:=0

func _ready() -> void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func configure(model: BoardModel,cell_pitch: float,marks: bool = false) -> void:
	board=model
	pitch=cell_pitch
	marked=marks
	custom_minimum_size=Vector2.ONE*(pitch*8+16)
	invalidate()

func invalidate() -> void:
	redraw_requests+=1
	queue_redraw()

func set_ghost(piece: PieceModel,info: Dictionary) -> void:
	if ghost==info and ghost_piece==piece: return
	ghost=info.duplicate()
	ghost_piece=piece
	invalidate()

func to_local_cell(position_global: Vector2) -> Vector2i:
	return Vector2i(((position_global-global_position-Vector2(8,8))/pitch).floor())

func _draw() -> void:
	var start:=Time.get_ticks_usec()
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE*(pitch*8+16)),Tokens.BOARD_WELL)
	var texture:=PieceView.texture()
	for y in 8:
		for x in 8:
			var rect:=Rect2(Vector2(8,8)+Vector2(x,y)*pitch,Vector2.ONE*pitch)
			draw_texture_rect_region(texture,rect,Rect2(0,640,128,128))
	if board!=null:
		for y in 8:
			for x in 8:
				var family: int=board.cells[y][x]
				if family<0: continue
				draw_texture_rect_region(texture,Rect2(Vector2(8,8)+Vector2(x,y)*pitch,Vector2.ONE*pitch),Rect2(128 if marked else 0,family*128,128,128))
	if ghost_piece!=null and not ghost.is_empty():
		for cell in ghost_piece.shape:
			var p: Vector2i=ghost.origin+cell
			if p.x<0 or p.x>7 or p.y<0 or p.y>7: continue
			var rect:=Rect2(Vector2(8,8)+Vector2(p)*pitch,Vector2.ONE*pitch)
			var tint:=Color(1,1,1,0.55) if ghost.valid else Color(Tokens.ERROR,0.6)
			draw_texture_rect_region(texture,rect,Rect2(0,ghost_piece.color*128,128,128),tint)
			if not ghost.valid: draw_texture_rect_region(texture,rect,Rect2(128,640,128,128))
			else: draw_rect(rect.grow(-pitch*0.08),Color(1,1,1,0.7),false,2)
	draw_count+=1
	last_draw_us=Time.get_ticks_usec()-start
