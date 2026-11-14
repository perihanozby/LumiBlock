# Godot 4.7.2 API verification

Engine executed: 4.7.2.stable.official.ed1daf0bf.

Baseline existing BoardModel/PieceModel scripts and JSON/FileAccess calls parse and execute in the headless core suite. New APIs require `tools/probe_api.gd` execution before use. Project-local environment routing verified by baseline runs without user-directory write errors. Certificate-store warning is environmental; no script parser error was observed.

Executed `tools/probe_api.gd`, exit 0. Raw signatures: `build/evidence/api-probe.txt`.

- `Input.vibrate_handheld(duration_ms: int = 500, amplitude: float = -1.0)` exists.
- `DisplayServer.get_display_safe_area() -> Rect2i` exists.
- `Image.load_svg_from_string(svg_str: String, scale: float = 1.0) -> Error` exists.
- `FontFile.has_char(char: int) -> bool`, `Engine.get_license_text() -> String`, `Engine.get_copyright_info() -> Array[Dictionary]` exist.
- `HashingContext.start(HashType) -> Error` and static `FileAccess.get_sha256(path: String) -> String` exist.
- All six probed project settings exist: quit_on_go_back defaults true; stretch/aspect defaults keep; emulate_touch_from_mouse defaults false; emulate_mouse_from_touch defaults true; fallback defaults en; default_bus_layout defaults res://default_bus_layout.tres.
- `--script` cannot compile a dependency that refers to the SaveService autoload global in this project. Pure tests avoid main.gd; UI/service tests must instantiate actual autoloads through a scene runner.
- Windows PowerShell policy blocks direct .ps1 execution; use `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1` (process-only; does not change machine policy).
- Runtime probe also verifies `Logger._log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace])` and `OS.add_logger/remove_logger(Logger)`. Runner uses these to catch parse and runtime errors, including push_error originating from C++ with a GDScript backtrace. A deliberately emitted error is recorded as FAIL. This closes the case where a suite aborts but the runner would otherwise print PASS.
