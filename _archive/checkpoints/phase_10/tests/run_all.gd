extends SceneTree

var failures := 0
var checks := 0
var records := PackedStringArray()
var error_capture: ErrorCapture
var current_blocked:=""
var blocked_suites:=0

func blocked(reason: String) -> void:
	current_blocked=reason

class ErrorCapture extends Logger:
	var errors: Array[String] = []
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if not (file == "platform/windows/os_windows.cpp" and _function in ["get_system_ca_certificates","get_system_dir"]):
			errors.append("%s:%d %s %s" % [file,line,code,rationale])

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL " + message)
		records.append("FAIL " + message)

func check_eq(a: Variant, b: Variant, message: String) -> void:
	check(a == b, "%s: expected %s, got %s" % [message, str(b), str(a)])

func _init() -> void:
	call_deferred("run_all")

func run_all() -> void:
	error_capture = ErrorCapture.new()
	OS.add_logger(error_capture)
	for directory in ["res://tests/unit", "res://tests/integration"]:
		var files := DirAccess.get_files_at(directory)
		files.sort()
		for file in files:
			if not file.begins_with("test_") or not file.ends_with(".gd"): continue
			var before := failures
			current_blocked=""
			var errors_before := error_capture.errors.size()
			var start := Time.get_ticks_usec()
			var script = load(directory + "/" + file)
			if script == null or not script.can_instantiate():
				check(false, file + " cannot compile")
			else:
				var suite = script.new()
				if not suite.has_method("run"): check(false, file + " has no run(t)")
				else: suite.run(self)
			for error in error_capture.errors.slice(errors_before): check(false,"engine script error: "+error)
			var status: String="FAIL" if failures!=before else ("BLOCKED" if current_blocked!="" else "PASS")
			if status=="BLOCKED": blocked_suites+=1
			var result := "%s %s (%.2f ms)%s" % [status,file,(Time.get_ticks_usec()-start)/1000.0," "+current_blocked if current_blocked!="" else ""]
			print(result)
			records.append(result)
	var summary := "%d checks, %d failures" % [checks, failures]
	print("Blocked suites: "+str(blocked_suites))
	print(summary)
	records.append(summary)
	var output := FileAccess.open("res://tests/last_run.txt", FileAccess.WRITE)
	if output == null:
		failures += 1
		print("FAIL cannot write tests/last_run.txt")
	else:
		output.store_string("\n".join(records) + "\n")
		output.close()
	OS.remove_logger(error_capture)
	quit(1 if failures > 0 else 0)
