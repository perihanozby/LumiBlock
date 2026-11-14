# Current test report — 2026-11-14

Fresh resume baseline: parser exit 0; core exit 0, 26329 checks, 0 failures. Exact final ten lines were shown to the user before Phase 3. Evidence: build/evidence/phase3-resume-*.

Final Phase 6 verification:

| Executed check | Result | Evidence |
|---|---|---|
| Godot headless editor parser | PASS, exit 0; no script/parse error | build/evidence/phase6-final-parser.* |
| Unit/integration suite | PASS, exit 0; 30963 checks, 0 failures | build/evidence/phase6-final-core.* |
| Real OpenGL desktop UI suite | PASS, exit 0; UI: 1953 checks, 0 failures | build/evidence/phase6-final-ui.* |
| UI drag-controller bot | PASS, 200 moves across 8 games in final run | same UI log |
| Atlas regeneration | PASS, two executed bakes produce identical PNG SHA-256 | build/evidence/atlas-determinism.txt |
| Board rendering | PASS desktop proxy; final maximum 111 us over repeated 64-cell draws, zero idle invalidations, no Resource increase | same UI log |
| Review screen capture | PASS generation, exit 0; 158 screen fixtures at seven sizes and larger text samples | build/evidence/phase6-review-capture.* |
| Locale contact sheet | PASS generation, exit 0; 780x1688 | build/evidence/phase6-contact.* |
| Human visual approval | BLOCKED, awaiting written user review | docs/review/REVIEW_PACK_1/index.md |

The UI suite executes real screen controls, navigation/modals, reset/restart confirmation, fixture statistics, independent classic/daily flow and rollover, 16 live language choices, drag ownership/invalid/cancel paths, real tutorial clear, actual bus mute/volume settings, type sizes and horizontal bounds at seven window sizes, injected safe areas, back routing and lifecycle save. Test profiles are isolated inside the workspace. The helper and both runners reject script errors even when the engine would otherwise exit 0.

Scope limits: U-08 full audio/haptic/FX observability is Phase 7; no generated audio/pattern/effect result is claimed. Fonts could not download from the approved official source and use built-in/system fallback. Only core non-English navigation strings are drafted; full localization and native review remain Phase 8. Physical-device results and Android exports are NOT RUN/BLOCKED as recorded in ACCEPTANCE_MATRIX.md. No new APK, device command, package-ID change, signing-key creation, upload or golden screenshot baseline occurred.

Historical 10000-game balance evidence remains in BALANCE_REPORT.md; it was not rerun for these UI changes. Older prototype reports are explicitly historical. Current evidence and resume instructions are CODEX_PROGRESS.md and ACCEPTANCE_MATRIX.md. The complete product Definition of Done is not yet satisfied; this checkpoint is the requested Phase 6 human review gate.
