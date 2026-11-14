extends Node

# Settings and interaction requests are observable on desktop; pattern playback is Phase 7.
var request_count:=0

func _ready() -> void:
	SettingsService.changed.connect(func(key,value):
		if key=="haptics" and value: pulse("tap"))

func pulse(_kind: String, _amount: int = 1) -> void:
	if SettingsService.values.get("haptics",false): request_count+=1
