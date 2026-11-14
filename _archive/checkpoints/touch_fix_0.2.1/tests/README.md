# Tests

From the project directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
```

This imports scripts with Godot 4.7.2, rejects script/parser errors even when Godot exits 0, then executes tests/run_all.gd. Unit/integration suites expose run(t) and use check/check_eq rather than bare assert. The runner discovers suites, captures Godot engine errors, prints each result, writes tests/last_run.txt, and exits 1 on failures. It filters only the observed Windows system-directory and certificate-store environment errors.

Both an intentionally failed check and an intentionally emitted engine error were exercised and removed. Evidence: build/evidence/runner-negative-probe.* and runner-runtime-negative.*. tests/test_core.gd now delegates to this runner; its old assertions are covered by unit tests including test_legacy_models.gd.

Environment helper directs runtime data, temp files and Android user-home paths inside the workspace. Test profiles never touch the user's existing external Godot saves. No device commands are part of the test suite.

Long balance run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command ". ./tools/environment.ps1; Invoke-GodotChecked -Arguments @('--headless','--path','.','--script','res://tools/sim_balance.gd') -Evidence 'balance'"
```

Physical-device, visual, audio listening and native translation review require separate evidence and approval. Current results are in docs/ACCEPTANCE_MATRIX.md; older reports are historical.

Desktop UI: use Invoke-GodotChecked with --path . --rendering-driver opengl3 res://tests/ui_runner.tscn. Stress: same flags and res://tools/stress_play.tscn. Screenshot suite: res://tools/review_capture.tscn -- --pack2 (review) or -- --actual (regression output); compare with --headless --script res://tools/compare_screens.gd. Golden images were authorized by Review1 approval/Review2 waiver; do not overwrite them merely to hide regressions. All capture fixtures now fail on save errors. The 10,000-step fractional-time diagnostic is tools/probe_save_precision.gd; regular runner includes a bounded regression and tamper tests.

Touch-only regression selection:run ui_runner.tscn with -- --suite=test_touch_pipeline.gd (all suites remain default;zero matching suites fails). The real windowed viewport path uses Input.parse_input_event(ScreenTouch/ScreenDrag,index0),both pointing-emulation directions and native mouse fields. No Control handler/signal is called to simulate gestures. Reproduction before fix:exit1/four failures;repaired pipeline and full UI pass. See docs/TOUCH_INPUT_FIX.md.
