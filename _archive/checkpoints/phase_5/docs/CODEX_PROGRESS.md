# LumiBlock implementation progress

2026-11-14, Europe/Istanbul. Authoritative request: MASTER_IMPLEMENTATION_PROMPT.md.

Current phase: Phase 2 gate PASS; Phase 3 is next. Phases 3–10 have not started; the overall Definition of Done is not satisfied. No technical blocker prevents starting Phase 3; unfinished implementation must not be labelled BLOCKED.

## Resumed work — Phase 3 (2026-11-14)

Fresh baseline rerun before implementation: parser exit 0 without script/parse errors; run_all exit 0, `26329 checks, 0 failures`. User was shown its exact final 10 stdout lines. Evidence: build/evidence/phase3-resume-*.

Implemented theme tokens/factory, 12 reusable component scenes/scripts, AppRoot, ScreenRouter, settings/localization services plus explicitly staged audio/haptics interfaces, 134 English source keys and registration of all 16 existing translation resources. Non-English values are English staging placeholders until Phase 8, explicitly documented in localization/REVIEW.md. Download of authorized Manrope from official Google Fonts GitHub failed to connect; per request, built-in font fallback is used and no alternate source was searched. Font coverage BLOCKED(font); download instructions and OFL requirements in assets/fonts/README.md and docs/FONTS.md.

UI router/component run: exit 0, `UI: 22 checks, 0 failures`. Initial inference/BOM issues were fixed and rerun; no script errors accepted. Phase 3 core/localization gate is running. Next: finish that gate, checkpoint Phase 3, then implement Phase 4 atlas/dirty board rendering and performance tests. Package/device/privacy decisions unchanged.

Phase 3 gate PASS: parser/boot exit 0; core/localization `30921 checks, 0 failures`, exit 0; router/components `UI: 22 checks, 0 failures`, exit 0. L-01/L-02/L-03 structural checks PASS (not completed non-English translations). L-05 BLOCKED(font). No visible gameplay screens are claimed yet. Phase 4 is next; create/bake atlas, implement views with dirty redraw, measure real desktop renderer and produce state sheet before Phase 5.

## Phase 4

Implemented pure CPU four-by-four supersampled OKLab atlas bake, rounded SDF edges, five mark families, lifted/socket/hatch/flash/glow textures, BoardView/PieceView/TrayView, dirty redraw and deterministic state-sheet capture. Two bakes exit 0 and PNG SHA-256 values match (`build/evidence/atlas-determinism.txt`). Atlas imported lossless with mipmaps and linear sampling. Inspected atlas and actual OpenGL 45-state capture, `tests/screenshots/actual/cube_states.png`; no human approval claimed.

Actual NVIDIA MX130 OpenGL compatibility UI run exit 0: `UI: 85 checks, 0 failures`; 64 occupied-cell drawing maximum 129 microseconds over 60 invalidations, zero idle invalidations in five seconds, no Resource-count increase during idle/repeated draws. Evidence `build/evidence/phase4-renderer-ui.*`; bake/capture evidence `phase4-bake.*`, `phase4-rebake.*`, `cube-capture.*`. Desktop proxy only; phone performance remains BLOCKED(permission).

Specification discrepancy recorded: 512x768 RGBA8 base level is 1.5 MiB, and mandated mipmaps add approximately 0.5 MiB. This exceeds the stated 1.6 MiB uncompressed VRAM budget; retained the specifically required atlas/mipmaps configuration and do not claim the memory budget PASS. A compressed GPU format or changed budget requires later resolution.

Next: checkpoint Gate 4, implement single-owner DragController/DragLayer and Game screen (Phase 5), then synthetic pointer and 200-move UI bot tests. No device command or package change.

Gate 4 PASS: final core/atlas/localization runner `30929 checks, 0 failures`, exit 0; parser exit 0. The test's original Image.load_from_file emitted an export warning; switched to Image.load_png_from_buffer for source-image inspection and reran clean. V-03/V-04, P-01/P-06 PASS; P-02 desktop portion PASS (129 us), device portion BLOCKED. Human visual and memory-budget acceptance remain open. Checkpoint refreshed after the successful gate; proceed to Phase 5.

## Phase 5 gate PASS

Implemented GameScreen (Control scene), SafeAreaContainer, DragController, DragLayer and FX layer boundary. Single touch-event path, owner index, fixed empty slots, release resolver equality, cancel on focus/pause/system touch/resize/modal/timeout, lockout and live HUD updates. Synthetic direct-event tests and real desktop OpenGL runner: parser exit 0; `UI: 910 checks, 0 failures`, exit 0. Bot: `UI bot: 200 moves, 5 games`; no script errors. Evidence `build/evidence/phase5-desktop-ui.*`, `phase5-parser.*`. I-02–I-07 automated portions PASS; human feel remains untested. No physical-device action.

Phase 6 next: real Home/Pause/Game Over/Daily/Stats/Settings/language/About/Privacy/Tutorial screens, every control exercised, responsive and locale review captures. Stop at Human Design Review #1 after preparing a reviewable pack; no approval is inferred.

## Phase 0

- Archived original main.gd, main.tscn and previous acceptance matrix under `_archive/v0.1.0_prototype/` before editing production code.
- Verified engine 4.7.2.stable.official.ed1daf0bf and Temurin 17.0.21. SDK platforms android-35 and android-37.0; build-tools 35.0.0 and 37.0.0 are present. No device action executed.
- Baseline parser exit 0, no script parser errors; baseline test_core exit 0, last test line: `LumiBlock core tests passed`. These are baseline observations, not acceptance results. Root-certificate-store warnings occur in the sandbox. Evidence: `build/evidence/baseline-*`.
- Helpers redirect APPDATA, LOCALAPPDATA, USERPROFILE, TEMP and Android user directories inside the project. Actual player saves outside the workspace are not accessed.
- Preserved all design files and translation resources. Matrix initialized from every acceptance row with NOT RUN.
- User approved com.perih.lumiblock, to apply only in Phase 10 after manifest checks. No privacy URL: R-04 BLOCKED(user), URL row must be hidden. Official Manrope/Noto font downloads authorized; fallback to default and BLOCKED(font) if unavailable.

## Current work / next three actions

1. Execute audit reproductions and API probes; record Phase 0 gate.
2. Implement Phase 1 pure domain and reliable test runner; run Gate 1 without skipping failures.
3. Only after Gate 1 passes, implement schema v2 migration/recovery and disposable-path persistence tests.

Resume: `.\tools\run_tests.ps1`. Build/capture helpers currently report their actual unimplemented gate rather than performing incomplete exports.

### Phase 0 gate result

PASS: archive, progress, matrix and API notes exist; baseline commands executed, exit 0. All five requested audit findings CONFIRMED (F-01/F-02 and F-05 partly by explicit source reasoning; no unsafe out-of-bounds access was executed). Executed reproduction exit 0, evidence `build/evidence/audit-reproductions.txt`; last line `F-23 CONFIRMED: JSON roundtrip 9007199254740993 -> 9007199254740992.` API probe exit 0. An initial audit probe failed because --script cannot resolve main.gd's autoload; corrected probe uses source reasoning for F-02 and reports this limitation.

### Phase 1 in progress

Implemented BoardModel atomic snapshots/independent line counts, full catalog, mulberry32, generator, scoring config/grace, GameSession fixed slots/restore evaluation, daily templates, stats tracker, drop resolver, layout metrics, locale formatter, colour math and test discovery. Deliberate failing test alone produced `178 checks, 1 failures`, Godot exit 1, with no script errors; removed afterward. Evidence `build/evidence/runner-negative-probe.*`.

No later phase is started until Gate 1 is green. Package ID remains unchanged. R-04 BLOCKED(user); no policy URL exists. Current visual/audio/native-language/device requirements remain unverified.

### Phase 1 gate PASS (2026-11-14)

- Final parser exit 0 without SCRIPT ERROR/Parse Error. `run_all.gd`: `26240 checks, 0 failures`, exit 0. Prototype scene smoke: `Prototype compatibility: 0 failures`, exit 0. Known Windows system-directory/certificate warnings remain visible in stderr and are not project script failures.
- 10,000-game simulation exited 0. Mean placements 41.38, median 32, p10 14, p90 80; mean score 4020.28; unfinished 0; first-level guarantee failures 0 (0.0000%). Raw games `build/evidence/balance-games.jsonl`; report `docs/BALANCE_REPORT.md`.
- C-01 through C-12, I-01, V-01/V-02 PASS. U-13 pure metrics PASS; full row intentionally NOT RUN until screenshots and actual controls are verified. UI-specific rows remain NOT RUN. This is the specified Phase 1 metrics-only gate, not visual approval.
- Existing prototype now handles null slots and correct scoring result fields. Its scene test exercises empty-slot touch/release, unchanged remaining slots, menu save, slot-preserving restore and no-move restore rejection. Still uses the legacy persistence/UI until later phases.
- Git metadata is explicitly read-only in the supplied permission profile; checkpoint fallback used. Copies: `_archive/checkpoints/phase_0/`, `_archive/checkpoints/phase_1/` (timestamp and files). No attempt to change Git permissions or write outside the project.

Next 3 actions: implement schema v2 validation/canonical checksums; migrate real v1 fixtures and test disposable-path recovery/atomic failure; run Phase 2 gate before foundations/UI work. Resume command: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1`.

### Phase 2 implementation and verification

Files: core/save_schema.gd, core/save_migrations.gd, scripts/save_service.gd; schema/roundtrip/corruption/migration/atomic tests; seven tests/fixtures/save_v1_*.json files; docs/SAVE_FORMAT.md. A temporary legacy adapter keeps the single-scene prototype functioning until AppRoot uses v2 directly. This adapter intentionally discards legacy engine RNG state during conversion; only pure GameSession v2 round trips establish exact stream restoration at this stage.

Executed tests: valid Windows replacement/previous-main backup, exact v1 one-time backup, healthy/partial/corrupt/float/daily/missing-session/legacy-session fixtures, bad checksums/types, quarantined exact bytes, future-schema write rejection, injected rename failure and retry, unknown extensions, numeric clamps/coercion. The scene smoke additionally checks 250 ms debounce/latest-data retention and the restored-session flag fix. Scene result: `Prototype compatibility: 0 failures`, exit 0 (`build/evidence/phase2-prototype-smoke.*`). Most recent unit/integration result before final rerun: `26324 checks, 0 failures`.

The first corrupt-save test correctly exposed JSON.parse_string logging engine errors. Replaced it with JSON.new().parse() and explicit parse-result checking, so damaged user data is handled without a script/engine error. Numeric canonicalization also now normalizes unknown integral values and string keys. No remaining failure is hidden or filtered.

## Remaining scope (not dropped)

Phases 3–10 remain NOT RUN, including the Control-based AppRoot/screens/router/components, Tokens/ThemeFactory, atlas baking/rendering, DragController/UI event tests, real daily/statistics/settings/tutorial screens, all effects/audio/haptics, complete translations/font coverage, visual review packs, lifecycle/performance hardening and Android/release exports. The build and screenshot helpers deliberately report NOT RUN until their implementations exist. The old APK in build is not a new result. Native UI still uses prototype geometry and has known remaining audit findings; pure resolver/session tests do not establish final touch feel.

User decisions remain: official font downloads approved but not yet attempted; package com.perih.lumiblock approved only for Phase 10 after manifest checks; privacy URL absent, R-04 BLOCKED(user). Device actions have not been authorized or executed this session. No keystore creation, upload or package-ID modification occurred.

Exact next 3 actions:
1. Start Phase 3: probe the remaining Control/router/theme APIs and implement Tokens, ThemeFactory, components, AppRoot and ScreenRouter; point main_scene to AppRoot only after its boot test passes.
2. Implement Settings/Localization services and font fallback chains; attempt only approved official fonts with OFL files, keeping all writes inside the project; implement English keys and 16 translation registrations/checks.
3. Run Phase 3 boot/router/localization gates. Proceed to Phase 4 atlas and BoardView only when those gates pass. Preserve existing translation resources and design archive.

Resume: read this file, ACCEPTANCE_MATRIX.md, API_NOTES.md, and MASTER_IMPLEMENTATION_PROMPT.md section list, then `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1`. No permission question is needed to continue the authorized implementation.

### Final Phase 2 checkpoint evidence

Final parser exit 0, no SCRIPT ERROR/Parse Error. Final `run_all.gd` exit 0, last summary line exactly: `26329 checks, 0 failures`. Evidence: `build/evidence/run-all.stdout`, `run-all.stderr`, `parser.stdout`, `parser.stderr`; immutable copies under `build/evidence/phase2-final-*`. S-01–S-07 PASS at the domain/persistence gate; S-08 lifecycle remains NOT RUN. Persisted finished-session reopening was exercised through SaveService plus a new StatsTracker and did not recount; actual replacement Game Over UI remains U-04 NOT RUN. Session and piece extension fields survive GameSession serialization as well as raw profile saves.

Checkpoint copied to `_archive/checkpoints/phase_2/` with timestamp and source-file list. Historical reports are clearly labelled and original reports retained under `_archive/v0.1.0_prototype/docs/`; TEST_REPORT.md now describes only this session. Remaining phases have not been silently removed or mislabeled as blocked. The current code is tested, but the requested full redesign is incomplete.

## Constraints and status interpretation

The request initially says exactly three statuses, but later sections 16/18 explicitly require NOT RUN for initial/unexecuted work. The later, specific rule wins. Visual, audio and native translation review remain BLOCKED until reviewed. Physical device actions require a fresh explicit approval listing commands.
