extends RefCounted

const Save = preload("res://scripts/save_service.gd")

func run(t) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=12345
	var tray := PieceCatalog.generate(rng)
	t.check_eq(tray.size(),3,"legacy tray size")
	for piece in tray:
		t.check(BoardModel.new().can_place(piece.shape,Vector2i.ZERO),"legacy generated typed shape")
		var restored := PieceModel.from_dict(piece.to_dict())
		t.check_eq(restored.shape,piece.shape,"legacy piece roundtrip shape")
		t.check_eq(restored.color,piece.color,"legacy piece roundtrip colour")
	t.check(not PieceCatalog.is_valid_shape([Vector2i.ZERO,Vector2i.ZERO]),"duplicate shape rejected")
	t.check(not PieceCatalog.is_valid_shape([Vector2i.ZERO,Vector2i(2,0)]),"disconnected shape rejected")
	t.check_eq(PieceCatalog.normalized([Vector2i(4,4),Vector2i(5,4)]),[Vector2i.ZERO,Vector2i.RIGHT],"normalization")
	var data := {"score":42,"piece":tray[0].to_dict()}
	t.check_eq(int(Save.decode_payload(Save.encode_payload(data)).score),42,"legacy decoder roundtrip")
	t.check(Save.decode_payload("not-json").is_empty(),"legacy corrupt decoder baseline")
	t.check(Save.decode_payload('{"version":999,"data":{}}').is_empty(),"legacy future decoder baseline (not a safe recovery claim)")
	t.check(ScoringEngine.placement_score(3,1,2)>0,"legacy scoring entry point")
