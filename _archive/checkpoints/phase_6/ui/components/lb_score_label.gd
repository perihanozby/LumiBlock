class_name LBScoreLabel
extends HBoxContainer

var value := 0

func set_value(number: int) -> void:
	value=number
	add_theme_constant_override("separation",0)
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var formatted := LocaleFormat.number(number,LocalizationService.locale)
	for character in formatted:
		var digit := Label.new()
		digit.theme_type_variation="LB_display_l"
		digit.text=character
		digit.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		digit.custom_minimum_size.x=Tokens.FONT_SIZES.display_l*float(SettingsService.values.get("text_scale",1.0))*0.64
		add_child(digit)
