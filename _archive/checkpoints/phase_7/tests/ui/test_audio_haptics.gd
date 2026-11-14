extends RefCounted

func run(t) -> void:
	AudioService.apply_settings()
	t.check_eq(AudioService.voices.size(),8,"fixed eight voice pool")
	t.check_eq(AudioService.streams.size(),20,"all event streams loaded through explicit export-safe paths")
	var before: int=AudioService.played_count
	AudioService.play("place")
	t.check_eq(AudioService.played_count,before+1,"enabled SFX plays a real player")
	SettingsService.set_value("sfx",false)
	AudioService.play("place")
	t.check_eq(AudioService.played_count,before+1,"disabled SFX no playback")
	SettingsService.set_value("sfx",true)
	t.check_eq(AudioService.last_event,&"toggle","enabling SFX plays sample")
	t.check_eq(AudioService.music.stream.format,AudioStreamWAV.FORMAT_IMA_ADPCM,"music imported IMA ADPCM")
	t.check_eq(AudioService.music.stream.loop_mode,AudioStreamWAV.LOOP_FORWARD,"music loops")
	AudioService.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	t.check(AudioService.music.stream_paused,"pause suspends music")
	AudioService.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	t.check(not AudioService.music.stream_paused,"resume restores music")
	var pulses: Array=[]
	var clock:=[1000]
	HapticsService.driver=func(ms,amplitude): pulses.append([ms,amplitude])
	HapticsService.clock=func(): return clock[0]
	HapticsService.mobile_override=true
	HapticsService.last_request_ms=-1000
	HapticsService.pulse("deny")
	t.check_eq(pulses.size(),1,"first haptic pulse emitted immediately")
	clock[0]+=20
	HapticsService.pulse("place")
	t.check_eq(pulses.size(),1,"40 ms throttle")
	clock[0]+=30
	HapticsService._process(0)
	t.check_eq(pulses.size(),2,"timer pattern emits second pulse")
	t.check_eq(pulses[0],[10,0.25],"deny duration/amplitude")
	SettingsService.set_value("haptics",false)
	clock[0]+=100
	HapticsService.pulse("perfect")
	t.check_eq(pulses.size(),2,"haptics off is no-op")
	HapticsService.driver=Callable()
	HapticsService.clock=Callable()
	HapticsService.mobile_override=null
	HapticsService.queue.clear()
