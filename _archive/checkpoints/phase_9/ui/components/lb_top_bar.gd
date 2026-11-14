class_name LBTopBar
extends HBoxContainer

signal back_pressed

func configure(key: String) -> void:
	var button := LBIconButton.new()
	button.text_key="common.back"
	button.pressed_action.connect(func(): back_pressed.emit())
	add_child(button)
	var title := Label.new()
	title.text=tr(key)
	title.theme_type_variation="LB_title"
	title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	add_child(title)
