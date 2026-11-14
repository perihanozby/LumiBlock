extends RefCounted

func run(t) -> void:
	var files: Array[String]=[]
	for file in DirAccess.get_files_at("res://assets/audio/sfx"):
		if file.ends_with(".wav"): files.append("res://assets/audio/sfx/"+file)
	files.append("res://assets/audio/music/calm_loop.wav")
	t.check_eq(files.size(),21,"all twenty SFX variants and music exist")
	for path in files:
		var bytes:=FileAccess.get_file_as_bytes(path)
		t.check(bytes.size()>44,"WAV has sample data "+path)
		if bytes.size()<44: continue
		t.check_eq(bytes.slice(0,4).get_string_from_ascii(),"RIFF","RIFF container")
		t.check_eq(bytes.decode_u16(22),1,"mono audio")
		t.check_eq(bytes.decode_u32(24),32000,"32 kHz source")
		t.check_eq(bytes.decode_u16(34),16,"16-bit source")
		var peak:=0.0
		for i in range(44,bytes.size()-1,2): peak=maxf(peak,absf(bytes.decode_s16(i)/32768.0))
		var expected: float=-12 if "/music/" in path else (-6 if "clear_" in path or "combo_step" in path or path.get_file().get_basename() in ["perfect","record","daily_done"] else -9)
		t.check(absf(linear_to_db(peak)-expected)<1,"peak normalisation "+path+" db="+str(linear_to_db(peak)))
		if "/music/" in path:
			t.check_eq((bytes.size()-44)/64000,48,"48 second loop")
			t.check(absf(bytes.decode_s16(44)-bytes.decode_s16(bytes.size()-2))/32768.0<0.02,"loop endpoint delta <0.02")
