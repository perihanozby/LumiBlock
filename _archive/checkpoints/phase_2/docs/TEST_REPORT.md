# Current test report — 2026-11-14

Phases 0 and 1 passed their gates. Phase 2 has executed schema/persistence and prototype integration coverage; the final runner output is the evidence below. Phases 3–10 are NOT RUN. The complete product Definition of Done is not satisfied.

Commands executed this session:

- Baseline headless editor import and old core suite: exit 0. Historical old suite output was unconditional; no acceptance result relies on that alone.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1`: parser gate plus discovered unit/integration suites. Current final output: build/evidence/run-all.stdout and parser.stdout; errors: corresponding stderr files. The helper rejects nonzero exits and script errors.
- Runner negative probes: intentional failed check produced Godot exit 1; intentional engine error also produced FAIL and exit 1. Both temporary tests were removed. Evidence: build/evidence/runner-negative-probe.* and runner-runtime-negative.*.
- `tools/sim_balance.gd`: exit 0, 10,000 games, no first-level guarantee failures, no unfinished games. See BALANCE_REPORT.md and build/evidence/balance-games.jsonl.
- Actual prototype scene harness: exit 0, `Prototype compatibility: 0 failures`. Covers fixed/null slots, empty capture/release, menu save, restore/no-move flag, integer statistics formatting and debounced persistence. Evidence: build/evidence/phase2-prototype-smoke.*.
- `tools/probe_api.gd` and audit reproduction tool: exit 0; signatures/findings recorded in API_NOTES.md and build/evidence/.

Known environmental stderr messages: Windows get_system_dir and certificate-store failures. No project script/parser error is accepted. Test profiles, logs and runtime state stay inside the workspace. Real external player saves were not accessed.

No new APK export, device command, visual approval, audio approval, native translation review, font download or final-screen UI runner was executed. Existing APK/screenshots and reports under _archive are historical artifacts, not current acceptance evidence. Package ID remains unchanged until authorized Phase 10 work. No upload/signing-key creation occurred.

Current authoritative statuses: ACCEPTANCE_MATRIX.md. Resume point and next actions: CODEX_PROGRESS.md.

Final Phase 2 runner summary: `26329 checks, 0 failures`; exit 0. Immutable evidence: build/evidence/phase2-final-tests.stdout and phase2-final-parser.stdout (and stderr files).
