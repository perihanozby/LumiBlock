class_name LBScoreLabel
extends HBoxContainer

var value := 0
var displayed:=0
var counter: Tween
var digits: Array[Label]=[]

func _ready() -> void:
	layout_direction=Control.LAYOUT_DIRECTION_LTR
	SettingsService.changed.connect(func(key,value):
		if key=="reduce_motion" and value:
			if counter!=null: counter.kill()
			_show_number(self.value)
		elif key=="text_scale":
			for digit in digits: digit.custom_minimum_size.x=Tokens.FONT_SIZES.display_l*float(value)*0.64)

func set_value(number: int) -> void:
	value=number
	add_theme_constant_override("separation",0)
	var formatted:=LocaleFormat.number(number,LocalizationService.locale)
	while digits.size()<formatted.length():
		var digit := Label.new()
		digit.theme_type_variation="LB_display_l"
		digit.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		digit.custom_minimum_size.x=Tokens.FONT_SIZES.display_l*float(SettingsService.values.get("text_scale",1.0))*0.64
		add_child(digit)
		digits.append(digit)
	if counter!=null: counter.kill()
	if SettingsService.reduce_motion() or not is_inside_tree(): _show_number(number)
	else:
		counter=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		counter.tween_method(_show_number,displayed,number,0.25)

func _show_number(number: int) -> void:
	displayed=number
	var formatted:=LocaleFormat.number(number,LocalizationService.locale)
	for i in digits.size():
		digits[i].visible=i<formatted.length()
		if i<formatted.length(): digits[i].text=formatted[i]
