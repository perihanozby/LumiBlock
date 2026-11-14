extends RefCounted

func run(t) -> void:
	var data := SaveSchema.validate({"settings":{"sfx_volume":9,"music_volume":-1,"effects":"bad","language":"xx","sfx":"bad"},"records":{"best_classic":-10,"best_daily":3.0},"stats":null,"history":"bad","sessions":{"classic":{"board":null,"tray":null,"score":"bad"}},"extra":{"future":3}})
	t.check_eq(data.settings.sfx_volume,1.0,"volume upper clamp")
	t.check_eq(data.settings.music_volume,0.0,"volume lower clamp")
	t.check_eq(data.settings.effects,"balanced","enum default")
	t.check_eq(data.settings.language,"system","language default")
	t.check_eq(data.records.best_classic,0,"nonnegative score")
	t.check(typeof(data.records.best_daily)==TYPE_INT,"integral field coercion")
	t.check_eq(data.extra.future,3,"unknown root key preserved")
	t.check(data.stats is Dictionary and data.history is Array,"bad containers repaired")
	t.check_eq(SaveSchema.checksum({"a":1,"b":{"c":2}}),SaveSchema.checksum({"b":{"c":2.0},"a":1.0}),"canonical integral floats and sorted keys")
	t.check(SaveSchema.valid_date("2024-02-29") and not SaveSchema.valid_date("2025-02-29"),"date validation")
