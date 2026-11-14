class_name LBButton
extends Button

signal pressed_action
@export var text_key := ""
@export_enum("primary","secondary","ghost") var variant := "secondary"
@export var large := false
var press_tween: Tween

func _init() -> void:
	# Ancestor ScrollContainer may cancel a press when it becomes a pan.
	mouse_filter=Control.MOUSE_FILTER_PASS

func _ready() -> void:
	custom_minimum_size=Vector2(Tokens.TOUCH,Tokens.BUTTON_L if large else Tokens.TOUCH)
	theme_type_variation="LB_"+variant
	pressed.connect(func():
		AudioService.play("ui_tap")
		HapticsService.pulse("tap")
		pressed_action.emit())
	button_down.connect(func(): _animate(0.97,0.07))
	button_up.connect(func(): _animate(1.0,0.09))
	LocalizationService.locale_changed.connect(relabel)
	SettingsService.changed.connect(func(key,value):
		if key=="reduce_motion" and value:
			if press_tween!=null: press_tween.kill()
			scale=Vector2.ONE)
	relabel()

func relabel() -> void:
	if text_key!="": text=tr(text_key)
	tooltip_text=text

func _animate(target: float, duration: float) -> void:
	if SettingsService.reduce_motion(): return
	pivot_offset=size/2
	if press_tween!=null: press_tween.kill()
	press_tween=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	press_tween.tween_property(self,"scale",Vector2.ONE*target,duration)
