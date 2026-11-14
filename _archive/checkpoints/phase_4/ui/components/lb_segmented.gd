class_name LBSegmented
extends HBoxContainer

signal selected(value: Variant)
var buttons: Array[LBButton] = []

func configure(keys: Array, values: Array, current: Variant) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	buttons.clear()
	for i in keys.size():
		var button := LBButton.new()
		button.text_key=keys[i]
		button.variant="primary" if values[i]==current else "secondary"
		button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.pressed_action.connect(func(): selected.emit(values[i]))
		add_child(button)
		buttons.append(button)
