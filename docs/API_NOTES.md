# Godot 4.7.2 API verification

Engine executed: 4.7.2.stable.official.ed1daf0bf.

Phase 3 rerun: `tools/probe_ui_api.gd` exit 0, signatures in `build/evidence/ui-api-probe.txt`. Control full-rect presets/global rectangles/layout_direction, Theme type variations/font sizes, StyleBoxFlat radius setter, Image create/fill/save_png, Translation.add_message, display cutouts and Tween.kill were probed. Font fallback is assigned through the verified `fallbacks` property in runtime tests. Router/components booted in the real autoload scene runner (22 checks, zero failures). Godot text scenes reject UTF-8 BOM; generated .tscn files are written UTF-8 without BOM. Warnings inferred from Variant are treated as errors by this engine configuration, so router/theme values have explicit types.

Phases 4–6 runtime verification: Image.load_png_from_buffer(FileAccess.get_file_as_bytes(...)) avoids the export warning emitted by Image.load_from_file on an imported texture. CPU Image RGBA8 atlas save is deterministic across two executed bakes. CanvasItem.draw_texture_rect_region, inherited Control layout_direction=L​TR on gameplay views, viewport texture get_image and RenderingServer.frame_post_draw all executed in NVIDIA OpenGL compatibility captures. get_rendering_device() is null for GL Compatibility even with a real GPU, so renderer identity is recorded from engine startup output, not that method.

AudioServer add_bus/get_bus_index/set_bus_name/set_bus_send/set_bus_mute/set_bus_volume_db and mute/volume readbacks executed in actual settings UI tests. Control font sizes, Timer.one_shot/start, application pause/focus/resume notifications, WM_GO_BACK_REQUEST, SceneTree.auto_accept_quit=false, and engine licence text retrieval were exercised through the scene runner. Real hardware vibration, Android OS notifications, device cutouts and phone performance remain unverified; no device commands were executed.

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
