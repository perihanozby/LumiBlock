extends SceneTree

class StateSheet extends Control:
	const STATES := ["resting","tray","lifted","valid ghost","invalid ghost","selected","clearing","combo glow","marked"]
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO,size),Tokens.BG_0)
		var texture:=PieceView.texture()
		for col in 9:
			draw_string(ThemeDB.fallback_font,Vector2(18+col*110,32),STATES[col],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Tokens.TEXT_BODY)
			for family in 5:
				var rect:=Rect2(16+col*110,56+family*130,96,96)
				var source:=Rect2(128 if col==8 else (256 if col==2 or col==5 else 0),family*128,128,128)
				if col==1: rect=rect.grow(-24)
				if col==2:
					draw_texture_rect_region(texture,rect.grow(8),Rect2(384,640,128,128),Color(0,0,0,0.45))
				if col==7: draw_texture_rect_region(texture,rect.grow(12),Rect2(384,640,128,128),Color(Tokens.FAMILIES[family].glow,0.3))
				draw_texture_rect_region(texture,rect,source,Color(1,1,1,0.55) if col==3 else (Color(Tokens.ERROR,0.6) if col==4 else Color.WHITE))
				if col==4: draw_texture_rect_region(texture,rect,Rect2(128,640,128,128))
				if col==5: draw_rect(rect,Tokens.ACCENT,false,2)
				if col==6: draw_texture_rect_region(texture,rect,Rect2(256,640,128,128),Color(1,1,1,0.6))

func _init() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size=Vector2i(1024,768)
	var sheet:=StateSheet.new()
	root.add_child(sheet)
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image:=root.get_texture().get_image()
	if image==null:
		print("FAIL capture requires a real rendering driver")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/screenshots/actual"))
	var error:=image.save_png("res://tests/screenshots/actual/cube_states.png")
	print("Cube state capture: "+str(error)+" "+str(image.get_size()))
	quit(0 if error==OK else 1)
