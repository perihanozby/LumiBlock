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
