extends Node

# Phase 6 settings wiring; generated streams and players arrive in Phase 7.
var request_count:=0

func _ready() -> void:
	for name in ["Music","SFX"]:
		if AudioServer.get_bus_index(name)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,name)
		AudioServer.set_bus_send(AudioServer.get_bus_index(name),"Master")
	SettingsService.changed.connect(func(_key,_value): apply_settings())
	apply_settings()

func apply_settings() -> void:
	for pair in [["Music","music"],["SFX","sfx"]]:
		var index:=AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_mute(index,not SettingsService.values[pair[1]])
		AudioServer.set_bus_volume_db(index,linear_to_db(maxf(0.0001,SettingsService.values[pair[1]+"_volume"])))

func play(_event: StringName, _step: int = 0) -> void:
	request_count+=1
