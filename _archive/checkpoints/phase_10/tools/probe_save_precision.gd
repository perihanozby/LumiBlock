extends SceneTree
const Service=preload("res://scripts/save_service.gd")
func _init() -> void:
	var data:=SaveSchema.defaults()
	var session:=GameSession.new(12345)
	for i in 10000:
		session.tick(0.0166666666666667)
		data.sessions.classic=session.to_dict()
		data=SaveSchema.validate(data)
		var encoded:=Service.encode_payload(data)
		if Service.decode_payload(encoded).is_empty():
			print("PRECISION FAIL elapsed=",session.elapsed_s," json=",encoded)
			quit(1)
			return
	print("Save precision: 10000 round trips PASS")
	quit()
