extends Node

const SaveTools = preload("res://tests/save_test_tools.gd")

var failures := 0
var checks := 0

func check(value: bool, message: String) -> void:
	checks+=1
	if not value:
		failures+=1
		print("FAIL "+message)

func check_eq(a: Variant,b: Variant,message: String) -> void:
	check(a==b,message+" expected="+str(b)+" got="+str(a))

func _ready() -> void:
	call_deferred("run_all")

func run_all() -> void:
	var logger=preload("res://tests/run_all.gd").ErrorCapture.new()
	OS.add_logger(logger)
	var selected:=""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--suite="): selected=argument.trim_prefix("--suite=")
	var suites:=0
	for file in DirAccess.get_files_at("res://tests/ui"):
		if not file.begins_with("test_") or not file.ends_with(".gd"): continue
		if selected!="" and file!=selected: continue
		suites+=1
		var isolated=SaveTools.service("ui_"+file.get_basename())
		SaveService.save_path=isolated.save_path
		isolated.free()
		SaveService.saving_disabled=false
		SaveService.save_game(SaveSchema.defaults(),true)
		SettingsService.values=SaveSchema.defaults().settings
		LocalizationService.apply_language("en")
		var before := failures
		var error_before: int=logger.errors.size()
		var script=load("res://tests/ui/"+file)
		if script==null or not script.can_instantiate(): check(false,"load "+file)
		else: await script.new().run(self)
		for error in logger.errors.slice(error_before): check(false,"engine error "+error)
		print(("PASS " if before==failures else "FAIL ")+file)
	check(suites>0,"at least one UI suite selected")
	print("UI: %d checks, %d failures" % [checks,failures])
	AudioService.stop_all()
	await get_tree().create_timer(0.1).timeout
	OS.remove_logger(logger)
	get_tree().quit(1 if failures else 0)
