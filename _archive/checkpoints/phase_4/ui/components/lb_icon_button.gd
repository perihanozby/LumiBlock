class_name LBIconButton
extends LBButton

@export var icon_name := "back"

func _ready() -> void:
	super._ready()
	var path := "res://assets/icons/%s.svg" % icon_name
	if ResourceLoader.exists(path): icon=load(path)
	expand_icon=true
	add_theme_constant_override("icon_max_width",Tokens.TOUCH-Tokens.SPACE[1])
