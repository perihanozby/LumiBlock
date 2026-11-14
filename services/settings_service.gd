extends Node

signal changed(key: String, value: Variant)
var values: Dictionary = {}

func _ready() -> void:
	if SaveService.profile.is_empty(): SaveService.load_game()
	values=SaveService.profile.settings.duplicate(true)

func set_value(key: String, value: Variant) -> void:
	if not values.has(key): return
	var draft := SaveService.profile.duplicate(true)
	draft.settings[key]=value
	values=SaveSchema.validate(draft).settings
	SaveService.profile.settings=values.duplicate(true)
	SaveService.save_game(SaveService.profile)
	changed.emit(key,values[key])

func reduce_motion() -> bool:
	return values.get("reduce_motion",false)
