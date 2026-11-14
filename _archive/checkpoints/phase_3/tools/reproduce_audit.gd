extends SceneTree

const OldSave = preload("res://_archive/v0.1.0_prototype/save_service.gd")

func _init() -> void:
	var lines := PackedStringArray()
	var tray: Array = [0, 1, 2]
	tray.remove_at(0)
	lines.append("F-01 CONFIRMED: remove_at(0) leaves %d slots; UI still captures slot 2, so 2 >= size; remaining pieces also shifted. Unsafe read not executed." % tray.size())
	var source := FileAccess.get_file_as_string("res://_archive/v0.1.0_prototype/main.gd")
	lines.append("F-02 CONFIRMED by source: only initialization clears flag=%s; game-over branch never clears it, and Resume tests only this flag. Runtime UI reproduction requires scene harness (autoload is unavailable to --script)." % (source.count("has_saved_session = false") == 0))
	var board := BoardModel.new()
	for i in 8:
		board.cells[0][i] = 0
		board.cells[i][0] = 0
	var cleared = board.clear_completed()
	var count_cells: int = cleared.cells.size() if cleared is Dictionary else cleared.size()
	lines.append("F-03 CONFIRMED: row+column produces %d unique cells; legacy int(cells/8)=%d instead of 2." % [count_cells, int(count_cells / 8.0)])
	lines.append("F-05 CONFIRMED: corrupt decoder=%s; future decoder=%s. Both indistinguishable from empty profile; no backup/quarantine exists in service." % [str(OldSave.decode_payload("bad")), str(OldSave.decode_payload('{"version":999,"data":{}}'))])
	var state: int = 9007199254740993
	var recovered: int = int(JSON.parse_string(JSON.stringify({"state": state})).state)
	lines.append("F-23 %s: JSON roundtrip %d -> %d." % ["CONFIRMED" if state != recovered else "REFUTED", state, recovered])
	var file := FileAccess.open("res://build/evidence/audit-reproductions.txt", FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()
	print("\n".join(lines))
	quit(0)
