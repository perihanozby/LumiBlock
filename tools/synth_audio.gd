extends SceneTree

const RATE:=32000
const NOTES:=[293.66,329.63,369.99,440.0,493.88,587.33,659.25,739.99]
var failures:=0

static func bell(t: float,f: float) -> float:
	if t<0 or t>0.75: return 0
	return (sin(TAU*f*t)+0.35*sin(TAU*2.76*f*t)+0.15*sin(TAU*5.4*f*t))*minf(1,t/0.003)*exp(-t/0.18)

static func tick(t: float,f: float) -> float:
	return sin(TAU*f*t)*exp(-t/0.005) if t>=0 else 0.0

func save_samples(path: String,samples: PackedFloat32Array,db: float) -> void:
	var peak:=0.0
	for i in samples.size():
		var edge:=minf(1,minf(i,samples.size()-1-i)/float(RATE*0.002))
		samples[i]*=edge
		peak=maxf(peak,absf(samples[i]))
	var scale:=db_to_linear(db)/maxf(peak,0.000001)
	var bytes:=PackedByteArray()
	bytes.resize(samples.size()*2)
	for i in samples.size():
		bytes.encode_s16(i*2,roundi(clampf(samples[i]*scale,-1,1)*32767))
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=RATE
	stream.stereo=false
	stream.data=bytes
	var error:=stream.save_to_wav(path)
	if error!=OK: failures+=1
	print("WAV %s samples=%d result=%d" % [path,samples.size(),error])

func event(name: String,duration: float,db: float = -9.0,step: int = 0) -> void:
	var samples:=PackedFloat32Array()
	samples.resize(roundi(duration*RATE))
	var rng:=SeededRng.new(42)
	for i in samples.size():
		var t:=i/float(RATE)
		var value:=0.0
		match name:
			"pickup": value=tick(t,880)
			"place": value=sin(TAU*(160*t-500*t*t))*exp(-t/0.025)+tick(t,1500)*0.15+(rng.next_float()*2-1)*maxf(0,1-t/0.002)*0.12
			"deny": value=tick(t,220)+tick(t-0.035,220)
			"ui_tap": value=tick(t,1200)
			"toggle": value=tick(t,1000)
			"combo_step": value=bell(t,NOTES[clampi(step,0,5)])
			"over":
				for n in 3: value+=bell(t-n*0.16,[440.0,369.99,293.66][n])
			_:
				var count:=step+1 if name.begins_with("clear_") else (3 if name=="record" else 5)
				for n in count: value+=bell(t-n*(0.06 if name.begins_with("clear_") else 0.10),NOTES[n])
				if name=="perfect": value+=sin(TAU*146.83*t)*sin(PI*t/duration)*0.35
		samples[i]=value
	var filename: String="combo_step_%d" % step if name=="combo_step" else name
	save_samples("res://assets/audio/sfx/%s.wav" % filename,samples,db)

func music() -> void:
	var chords:=[[146.83,185.0,220.0,277.18,329.63],[123.47,146.83,185.0,220.0,277.18],[98.0,123.47,146.83,185.0],[110.0,138.59,164.81,185.0,246.94]]
	var samples:=PackedFloat32Array()
	samples.resize(RATE*48)
	var rng:=SeededRng.new(20261114)
	var onsets: Array[float]=[]
	var pitches: Array[float]=[]
	var onset:=1.5
	while onset<48:
		onsets.append(onset)
		pitches.append(NOTES[rng.range_int(0,7)])
		onset+=3+rng.next_float()*2
	for i in samples.size():
		var t:=i/float(RATE)
		var value:=0.0
		for chord in 4:
			var local:=fposmod(t-chord*12,48)
			if local>15: continue
			var envelope:=minf(1,local/2.5)*clampf((15-local)/3,0,1)
			for frequency in chords[chord]:
				for detune in [-6.0,0.0,6.0]:
					var phase:=TAU*float(frequency)*pow(2,detune/1200)*local
					var lowpass:=0.7+0.3*sin(TAU*t/48)
					value+=(sin(phase)-lowpass*sin(phase*3)/9+lowpass*sin(phase*5)/25)*envelope*0.035
		for n in onsets.size():
			var local:=fposmod(t-onsets[n],48)
			if local<3: value+=bell(local,pitches[n])*0.05*clampf((3-local)/0.1,0,1)
		samples[i]=value*(0.9+0.1*sin(TAU*t/48))
	# Circular seam crossfade keeps the last/first samples continuous.
	var fade:=RATE/10
	for i in fade:
		var a:=samples[i]
		var b:=samples[samples.size()-fade+i]
		var blended:=lerpf(b,a,i/float(fade))
		samples[i]=blended
		samples[samples.size()-fade+i]=blended
	save_samples("res://assets/audio/music/calm_loop.wav",samples,-12)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/audio/sfx"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/audio/music"))
	for entry in [["pickup",0.04],["place",0.09],["deny",0.05],["ui_tap",0.025],["toggle",0.03],["perfect",0.9],["record",0.6],["over",0.7],["daily_done",1.0]]:
		event(entry[0],entry[1],-6 if entry[0] in ["perfect","record","daily_done"] else -9)
	for n in range(1,6): event("clear_%d" % n,0.28+0.06*(n+1),-6,n)
	for n in 6: event("combo_step",0.22,-6,n)
	music()
	print("Audio synthesis failures: "+str(failures))
	quit(1 if failures else 0)
