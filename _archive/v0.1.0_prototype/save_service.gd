extends Node

const PATH := "user://lumiblock_save.json"
const VERSION := 1

static func encode_payload(data: Dictionary) -> String:
	return JSON.stringify({"version": VERSION, "data": data})

static func decode_payload(raw: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(raw) != OK: return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary or not parsed.has("data") or not parsed.data is Dictionary: return {}
	if int(parsed.get("version", 0)) > VERSION: return {}
	return parsed.data

func save_game(data: Dictionary) -> bool:
	var file := FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(encode_payload(data)); file.close()
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH + ".tmp"), ProjectSettings.globalize_path(PATH))
	return error == OK

func load_game() -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null: return {}
	var parsed_data := decode_payload(file.get_as_text())
	file.close()
	return parsed_data
