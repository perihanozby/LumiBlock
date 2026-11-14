class_name LBSlider
extends HSlider

func _init() -> void:
	# Own the horizontal drag; bubbling it would let the parent steal jitter.
	mouse_filter=Control.MOUSE_FILTER_STOP
	custom_minimum_size=Vector2(Tokens.TOUCH,Tokens.TOUCH)
	min_value=0
	max_value=1
	step=0.01
