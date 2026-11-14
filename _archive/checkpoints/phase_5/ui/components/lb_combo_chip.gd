class_name LBComboChip
extends Label

func set_combo(value: int) -> void:
	visible=value>=2
	theme_type_variation="LB_caption"
	text=tr("game.combo").format({"n":value})
