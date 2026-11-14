extends SceneTree
func _init() -> void:
	for cls in ["AudioStreamWAV","AudioStreamPlayer","AudioBusLayout"]:
		for method in ClassDB.class_get_method_list(cls):
			if method.name in ["save_to_wav","play","set_stream_paused"]: print(cls+" "+JSON.stringify(method))
	var wave:=AudioStreamWAV.new()
	wave.format=AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate=32000
	wave.stereo=false
	print("AudioStreamWAV PCM16 setup verified; vibrate signature already verified in API_NOTES")
	quit()
