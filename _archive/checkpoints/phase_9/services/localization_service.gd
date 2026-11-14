extends Node

signal locale_changed
const LOCALES := ["en","tr","es","pt-BR","fr","de","it","ja","ko","zh-CN","ar","hi","id","vi","ru","th"]
const NATIVE_NAMES := ["English","Türkçe","Español","Português (Brasil)","Français","Deutsch","Italiano","日本語","한국어","简体中文","العربية","हिन्दी","Bahasa Indonesia","Tiếng Việt","Русский","ไทย"]
var locale := "en"
var ui_font: Font
var pseudo: Translation
var font_cache: Dictionary={}
var font_manifest: Dictionary={}

func _ready() -> void:
	if FileAccess.file_exists("res://assets/fonts/manifest.json"):
		var parser:=JSON.new()
		if parser.parse(FileAccess.get_file_as_string("res://assets/fonts/manifest.json"))==OK and parser.data is Dictionary: font_manifest=parser.data
	SettingsService.changed.connect(func(key,_value):
		if key=="language": apply_language(str(SettingsService.values.language)))
	apply_language(str(SettingsService.values.get("language","system")))
	if OS.is_debug_build(): _create_pseudo()

func set_language(code: String) -> void:
	SettingsService.set_value("language",code)

func apply_language(code: String) -> void:
	var pseudo_requested:=code=="en_XA" and OS.is_debug_build()
	if code=="system":
		code=OS.get_locale().replace("_","-")
		if not code in LOCALES: code=code.get_slice("-",0)
	locale=code if code in LOCALES or pseudo_requested else "en"
	TranslationServer.set_locale(locale)
	ui_font=font_chain(locale)
	locale_changed.emit()

func font_chain(code: String) -> Font:
	if font_cache.has(code): return font_cache[code]
	var main := load("res://assets/fonts/Manrope.ttf") as FontFile if ResourceLoader.exists("res://assets/fonts/Manrope.ttf") else null
	if main==null: return ThemeDB.fallback_font
	main=main.duplicate()
	var families := {"ar":"Arabic","hi":"Devanagari","th":"Thai","ja":"JP","ko":"KR","zh-CN":"SC"}
	var fallbacks: Array[Font] = []
	if families.has(code):
		for path in font_manifest.get(families[code],[]):
			if ResourceLoader.exists(path): fallbacks.append(load(path))
	main.fallbacks=fallbacks
	main.allow_system_fallback=true
	font_cache[code]=main
	return main

func _create_pseudo() -> void:
	pseudo=Translation.new()
	pseudo.locale="en_XA"
	if not FileAccess.file_exists("res://localization/strings.csv"): return
	var file:=FileAccess.open("res://localization/strings.csv",FileAccess.READ)
	file.get_csv_line()
	while not file.eof_reached():
		var row:=file.get_csv_line()
		if row.size()!=17: continue
		var text:=row[1]
		var accented:=""
		var placeholder:=false
		var replacements:={"a":"á","e":"ë","i":"ï","o":"ó","u":"ü","A":"Á","E":"Ë"}
		for character in text:
			if character=="{": placeholder=true
			accented+=str(replacements.get(character,character)) if not placeholder else character
			if character=="}": placeholder=false
		pseudo.add_message(row[0],"["+accented+" "+"~".repeat(ceili(text.length()*0.4))+"]")
	file.close()
	TranslationServer.add_translation(pseudo)
