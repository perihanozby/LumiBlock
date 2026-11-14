extends SceneTree
func _init() -> void:
	for method in ClassDB.class_get_method_list("TranslationServer"):
		if method.name in ["get_translation_object","standardize_locale","add_translation"]: print(JSON.stringify(method))
	quit()
