extends SceneTree

var failures:=0
func check(value: bool,message: String) -> void:
	if not value:
		failures+=1
		print("FAIL "+message)
func check_eq(a: Variant,b: Variant,message: String) -> void:
	check(a==b,message)
func _init() -> void:
	load("res://tests/unit/test_localization.gd").new().run(self)
	print("Localization failures: "+str(failures))
	quit(1 if failures else 0)
