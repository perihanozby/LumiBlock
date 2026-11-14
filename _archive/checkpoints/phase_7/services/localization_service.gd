extends Node

signal locale_changed
const LOCALES := ["en","tr","es","pt-BR","fr","de","it","ja","ko","zh-CN","ar","hi","id","vi","ru","th"]
const NATIVE_NAMES := ["English","Türkçe","Español","Português (Brasil)","Français","Deutsch","Italiano","日本語","한국어","简体中文","العربية","हिन्दी","Bahasa Indonesia","Tiếng Việt","Русский","ไทย"]
var locale := "en"
var ui_font: Font

func _ready() -> void:
	SettingsService.changed.connect(func(key,_value):
		if key=="language": apply_language(str(SettingsService.values.language)))
	apply_language(str(SettingsService.values.get("language","system")))

func set_language(code: String) -> void:
	SettingsService.set_value("language",code)

func apply_language(code: String) -> void:
	if code=="system":
		code=OS.get_locale().replace("_","-")
		if not code in LOCALES: code=code.get_slice("-",0)
	locale=code if code in LOCALES else "en"
	TranslationServer.set_locale(locale)
	ui_font=font_chain(locale)
	locale_changed.emit()

func font_chain(code: String) -> Font:
	var main := load("res://assets/fonts/Manrope.ttf") as FontFile if ResourceLoader.exists("res://assets/fonts/Manrope.ttf") else null
	if main==null: return ThemeDB.fallback_font
	main=main.duplicate()
	var families := {"ar":"Arabic","hi":"Devanagari","th":"Thai","ja":"JP","ko":"KR","zh-CN":"SC"}
	var fallbacks: Array[Font] = []
	if families.has(code):
		var path := "res://assets/fonts/NotoSans%s.ttf" % families[code]
		if ResourceLoader.exists(path): fallbacks.append(load(path))
	main.fallbacks=fallbacks
	main.allow_system_fallback=true
	return main
