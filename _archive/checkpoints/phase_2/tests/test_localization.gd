extends SceneTree

const REQUIRED_LOCALES: Array[String] = ["en", "tr", "es", "pt-BR", "fr", "de", "it", "ja", "ko", "zh-CN", "ar", "hi", "id", "vi", "ru", "th"]

func _init() -> void:
	var file := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	if file == null:
		push_error("Localization CSV could not be opened")
		quit(1)
		return
	var rows := file.get_as_text().strip_edges().split("\n")
	file.close()
	assert(rows.size() > 1)
	var header: PackedStringArray = rows[0].split(",")
	for locale in REQUIRED_LOCALES: assert(header.has(locale))
	for row in rows.slice(1):
		var columns: PackedStringArray = row.split(",")
		assert(columns.size() == header.size())
		for value in columns.slice(1): assert(not value.strip_edges().is_empty())
	print("LumiBlock localization completeness test passed")
	quit()
