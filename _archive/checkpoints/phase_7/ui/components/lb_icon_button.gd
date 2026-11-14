class_name LBIconButton
extends LBButton

@export var icon_name := "back"

func _ready() -> void:
	super._ready()
	var path := "res://assets/icons/%s.svg" % icon_name
	if ResourceLoader.exists(path): icon=load(path)
	expand_icon=true
	add_theme_constant_override("icon_max_width",Tokens.TOUCH-Tokens.SPACE[1])
	size_flags_vertical=Control.SIZE_SHRINK_CENTER
	for state in ["normal","hover","pressed","disabled"]:
		add_theme_stylebox_override(state,ThemeFactory.box(Tokens.SURFACE_HI,Tokens.BUTTON_RADIUS,Tokens.SPACE[0]))

func relabel() -> void:
	tooltip_text=tr(text_key)
	text=""
