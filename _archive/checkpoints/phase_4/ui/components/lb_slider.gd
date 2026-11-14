class_name LBSlider
extends HSlider

func _ready() -> void:
	custom_minimum_size=Vector2(Tokens.TOUCH,Tokens.TOUCH)
	min_value=0
	max_value=1
	step=0.01
