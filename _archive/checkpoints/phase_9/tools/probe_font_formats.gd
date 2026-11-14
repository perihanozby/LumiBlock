extends SceneTree
func _init() -> void:
	print("Font formats: "+str(ResourceLoader.get_recognized_extensions_for_type("FontFile")))
	quit()
