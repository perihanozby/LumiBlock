class_name LBIconButton
extends LBButton

@export var icon_name := "back"
var icon_texture: Texture2D
var mirrored:=false

func _ready() -> void:
	super._ready()
	var path := "res://assets/icons/%s.svg" % icon_name
	if ResourceLoader.exists(path): icon_texture=load(path)
	_update_icon()
	expand_icon=true
	add_theme_constant_override("icon_max_width",Tokens.TOUCH-Tokens.SPACE[1])
	size_flags_vertical=Control.SIZE_SHRINK_CENTER
	for state in ["normal","hover","pressed","disabled"]:
		add_theme_stylebox_override(state,ThemeFactory.box(Tokens.SURFACE_HI,Tokens.BUTTON_RADIUS,Tokens.SPACE[0]))

func relabel() -> void:
	tooltip_text=tr(text_key)
	text=""
	_update_icon()

func _update_icon() -> void:
	mirrored=icon_name=="back" and LocalizationService.locale=="ar"
	icon=null if mirrored else icon_texture
	queue_redraw()

func _draw() -> void:
	if mirrored and icon_texture!=null:
		var edge:=Tokens.TOUCH-Tokens.SPACE[1]
		var origin:=(size-Vector2.ONE*edge)/2
		draw_texture_rect(icon_texture,Rect2(origin+Vector2(edge,0),Vector2(-edge,edge)),false)
