class_name LBDialog
extends LBScreen

var column: VBoxContainer

func enter(params: Dictionary) -> void:
	super.enter(params)
	var scrim := ColorRect.new()
	scrim.color=Tokens.SCRIM
	add_child(scrim)
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := LBCard.new()
	card.custom_minimum_size=Vector2(320,0)
	center.add_child(card)
	column=VBoxContainer.new()
	card.add_child(column)
	var title := Label.new()
	title.text=tr(str(params.get("title","common.confirm")))
	title.theme_type_variation="LB_headline"
	column.add_child(title)
	var body := Label.new()
	body.text=tr(str(params.get("body","common.confirm")))
	body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size.x=288
	column.add_child(body)
	for choice in ["common.confirm","common.cancel"]:
		var button := LBButton.new()
		button.text_key=choice
		button.variant="primary" if choice=="common.confirm" else "secondary"
		button.pressed_action.connect(func():
			app.router.pop_modal()
			if choice=="common.confirm" and params.has("confirm"): params.confirm.call())
		column.add_child(button)
