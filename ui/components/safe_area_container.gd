class_name SafeAreaContainer
extends MarginContainer

var injected_area:=Rect2()
var safe_rect:=Rect2()
var last_logged_rect:=Rect2()

func _ready() -> void:
	get_viewport().size_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if not is_inside_tree(): return
	var viewport:=get_viewport_rect().size
	safe_rect=Rect2(Vector2.ZERO,viewport)
	if injected_area.has_area(): safe_rect=injected_area
	elif OS.has_feature("mobile"):
		var raw:=DisplayServer.get_display_safe_area()
		var physical:=Vector2(DisplayServer.window_get_size())
		if physical.x>0 and physical.y>0:
			var factor:=viewport/physical
			safe_rect=Rect2(Vector2(raw.position)*factor,Vector2(raw.size)*factor)
			if OS.is_debug_build() and safe_rect!=last_logged_rect:
				print("LUMIBLOCK_SAFE_AREA physical=",physical," raw=",raw," logical=",safe_rect," viewport=",viewport)
				last_logged_rect=safe_rect
	add_theme_constant_override("margin_left",roundi(safe_rect.position.x)+Tokens.MARGIN)
	add_theme_constant_override("margin_right",roundi(viewport.x-safe_rect.end.x)+Tokens.MARGIN)
	add_theme_constant_override("margin_top",roundi(safe_rect.position.y)+Tokens.MARGIN)
	add_theme_constant_override("margin_bottom",roundi(viewport.y-safe_rect.end.y)+Tokens.MARGIN)
