extends RefCounted

func run(t) -> void:
	var catalog := PieceCatalog.entries()
	t.check_eq(catalog.size(),37,"37 stable ids")
	var signatures := {}
	for id in catalog:
		var shape: Array[Vector2i] = catalog[id]
		t.check(PieceCatalog.is_valid_shape(shape),"connected unique " + id)
		t.check_eq(PieceCatalog.normalized(shape),shape,"normalized " + id)
		var signature := str(shape)
		t.check(not signatures.has(signature),"distinct " + id)
		signatures[signature] = true
	for raw in PieceCatalog.SHAPES:
		var shape: Array[Vector2i] = []
		shape.assign(raw)
		t.check(not PieceCatalog.id_for(shape).is_empty(),"legacy shape retained")
