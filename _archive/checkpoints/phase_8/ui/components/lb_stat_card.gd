class_name LBStatCard
extends LBCard

var title_label: Label
var value_label: Label

func configure(key: String, value: String) -> void:
	if title_label==null:
		var column := VBoxContainer.new()
		add_child(column)
		title_label=Label.new()
		title_label.theme_type_variation="LB_caption"
		column.add_child(title_label)
		value_label=Label.new()
		value_label.theme_type_variation="LB_title"
		column.add_child(value_label)
	title_label.text=tr(key)
	value_label.text=value
