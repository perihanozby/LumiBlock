class_name LBToggle
extends CheckButton

@export var text_key := ""

func _ready() -> void:
	custom_minimum_size.y=Tokens.TOUCH
	LocalizationService.locale_changed.connect(relabel)
	relabel()

func relabel() -> void:
	text=tr(text_key)
