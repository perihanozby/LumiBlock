extends RefCounted
const SaveTools=preload("res://tests/save_test_tools.gd")
const Service=preload("res://scripts/save_service.gd")
func run(t) -> void:
	var service=SaveTools.service("fractional_time")
	var data:=SaveSchema.defaults()
	var session:=GameSession.new(12345)
	for index in 120:
		session.tick(0.0166666666666667)
		data.sessions.classic=session.to_dict()
		var encoded:=Service.encode_payload(data)
		var decoded:=Service.decode_payload(encoded)
		t.check(not decoded.is_empty(),"fractional-time payload checksum roundtrip %d" % index)
		if not decoded.is_empty():
			t.check(absf(decoded.sessions.classic.elapsed_s-session.elapsed_s)<0.000000001,"fractional time retained")
			t.check_eq(decoded.sessions.classic.rng_state,session.rng.state,"exact PRNG unaffected")
		if index%20==0:
			t.check(service.save_game(data,true),"timed-session disk save")
			t.check(not service.load_game().is_empty(),"timed-session disk reload")
	var payload:=Service.encode_payload(data)
	t.check(Service.decode_payload(payload.replace('"score":0','"score":99')).is_empty(),"raw-byte fallback still rejects tampering")
	var duplicate:=payload.insert(payload.length()-1,',"data":{"tampered":true}')
	t.check(Service.decode_payload(duplicate).is_empty(),"duplicate root key cannot bypass checksum fallback")
	var nested:={"quoted":"escaped \\\"data\\\": {}","data":{"keep":true}}
	t.check_eq(Service.raw_data_json('{"app_version":"data","data":'+JSON.stringify(nested)+'}'),JSON.stringify(nested),"extract only root data; escaped quotes and nested keys")
	service.free()
