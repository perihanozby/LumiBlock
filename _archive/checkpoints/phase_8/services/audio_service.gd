extends Node

var request_count:=0
var played_count:=0
var last_event: StringName
var voices: Array[AudioStreamPlayer]=[]
var streams: Dictionary={}
var music: AudioStreamPlayer
var next_voice:=0
var shutting_down:=false
var playback_driver: Callable
var audio_device_available:=true
var paused_for_lifecycle:=false
const EVENTS:=["pickup","place","deny","ui_tap","toggle","perfect","record","over","daily_done","clear_1","clear_2","clear_3","clear_4","clear_5","combo_step_0","combo_step_1","combo_step_2","combo_step_3","combo_step_4","combo_step_5"]

func _ready() -> void:
	audio_device_available=DisplayServer.get_name()!="headless"
	for name in ["Music","SFX"]:
		if AudioServer.get_bus_index(name)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,name)
		AudioServer.set_bus_send(AudioServer.get_bus_index(name),"Master")
	SettingsService.changed.connect(func(_key,_value): apply_settings())
	for i in 8:
		var voice:=AudioStreamPlayer.new()
		voice.bus="SFX"
		add_child(voice)
		voices.append(voice)
	for event in EVENTS:
		var path: String="res://assets/audio/sfx/%s.wav" % event
		if ResourceLoader.exists(path): streams[event]=load(path)
	music=AudioStreamPlayer.new()
	music.bus="Music"
	if ResourceLoader.exists("res://assets/audio/music/calm_loop.wav"):
		music.stream=load("res://assets/audio/music/calm_loop.wav")
		if music.stream is AudioStreamWAV:
			music.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
			music.stream.loop_begin=0
			music.stream.loop_end=roundi(music.stream.get_length()*music.stream.mix_rate)
	add_child(music)
	SettingsService.changed.connect(func(key,value):
		if key=="sfx" and value: play("toggle"))
	apply_settings()

func apply_settings() -> void:
	for pair in [["Music","music"],["SFX","sfx"]]:
		var index:=AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_mute(index,not SettingsService.values[pair[1]])
		AudioServer.set_bus_volume_db(index,linear_to_db(maxf(0.0001,SettingsService.values[pair[1]+"_volume"])))
	if music!=null and music.stream!=null:
		if audio_device_available and SettingsService.values.music and not music.playing: music.play()
		elif not SettingsService.values.music: music.stop()

func play(event: StringName, step: int = 0) -> void:
	request_count+=1
	if shutting_down: return
	if not SettingsService.values.get("sfx",true): return
	if not audio_device_available and not playback_driver.is_valid(): return
	var key:=str(event)
	if event==&"combo_step": key="combo_step_%d" % clampi(step,0,5)
	if not streams.has(key) or voices.is_empty(): return
	var voice:=voices[next_voice]
	next_voice=(next_voice+1)%voices.size()
	voice.stop()
	voice.stream=streams[key]
	if playback_driver.is_valid(): playback_driver.call(voice)
	else: voice.play()
	last_event=event
	played_count+=1

func stop_all() -> void:
	shutting_down=true
	for voice in voices:
		voice.stop()
		voice.stream=null
		voice.free()
	voices.clear()
	if music!=null:
		music.stop()
		music.stream=null
		music.free()
		music=null
	streams.clear()

func _exit_tree() -> void:
	stop_all()

func _notification(what: int) -> void:
	if music==null: return
	if what==NOTIFICATION_APPLICATION_PAUSED:
		paused_for_lifecycle=true
		if music.playing: music.stream_paused=true
	elif what==NOTIFICATION_APPLICATION_RESUMED:
		paused_for_lifecycle=false
		music.stream_paused=false
