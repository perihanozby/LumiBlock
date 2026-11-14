# LumiBlock implementation progress

2026-11-15, Europe/Istanbul. Authoritative request: MASTER_IMPLEMENTATION_PROMPT.md.

Current phase: touch repair0.2.1/code3 complete;automated gates and authorized install/launch PASS;user phone gesture confirmation pending. User approved Review #1, waived Review #2, and explicitly instructed continuous Phase 7â€“10 execution. Authorized implementation is complete; remaining manual/release/spec requirements are BLOCKED below. No further ordinary approval question is pending.

## Latest authorization and decisions (2026-11-14)

- Review #1 visual direction approved by the user. Review #2 is waived; generate its evidence but do not stop for approval. Waiver is not native translation or audio-listening approval.

- Continue Phases 7, 8, 9 and 10 in order without stopping at phase boundaries. Make routine decisions from the master defaults and append task results here after every task.

- Exact device commands pre-authorized, with project-local ANDROID_USER_HOME: `adb devices`; `adb install -r build\lumiblock-debug.apk`; `adb shell am start -n <package>/<launchable-activity>`; `adb logcat -d`; `adb shell dumpsys gfxinfo/meminfo`; `adb shell screencap`. No other device commands are authorized. In particular no input injection, force-stop, kill, clear, uninstall, pull, or other shell commands.

- Keep the existing package through initial manifest checks; only after those checks pass apply approved `com.perih.lumiblock`, rebuild and reverify.

- Human listening, native translation review, production keystore, hosted privacy URL and Play account remain BLOCKED(user). Font download/coverage is resolved; atlas/mipmap budget conflict is explicitly BLOCKED(spec). No user question is needed for authorized local work.

Next three actions (user/external blockers): complete DEVICE_CHECKLIST plus audio/native review; provide production signing/privacy URL/Play setup and accepted store art; qualify cold/release startup and resolve the atlas budget conflict. No unblocked implementation task remains.

## Resumed work â€” Phase 3 (2026-11-14)

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

Implemented GameScreen (Control scene), SafeAreaContainer, DragController, DragLayer and FX layer boundary. Single touch-event path, owner index, fixed empty slots, release resolver equality, cancel on focus/pause/system touch/resize/modal/timeout, lockout and live HUD updates. Synthetic direct-event tests and real desktop OpenGL runner: parser exit 0; `UI: 910 checks, 0 failures`, exit 0. Bot: `UI bot: 200 moves, 5 games`; no script errors. Evidence `build/evidence/phase5-desktop-ui.*`, `phase5-parser.*`. I-02â€“I-07 automated portions PASS; human feel remains untested. No physical-device action.

Phase 6 next: real Home/Pause/Game Over/Daily/Stats/Settings/language/About/Privacy/Tutorial screens, every control exercised, responsive and locale review captures. Stop at Human Design Review #1 after preparing a reviewable pack; no approval is inferred.

## Phase 6 in verification

Implemented Control scenes for Home, Daily, Statistics, Settings, Pause, Game Over, language picker, About/engine licences, Privacy, and real drag-driven Tutorial. AppRoot owns separate classic/daily sessions, save triggers, confirm/restart/reset, statistics finalization, date rollover, router back/quit, lifecycle pause, and 15-second flush. Added original SVG icons. No privacy URL control is shown. Settings immediately update save state, actual audio bus mute/volume and text scaling; marks/assist update the active Game view. Generated audio assets, pattern playback and effects remain Phase 7, not claimed audible/physical functionality.

The last desktop UI run before final refinements: `UI: 1523 checks, 0 failures`, parser exit 0. Includes 200 drag-controller bot moves, tutorial real row clear, all navigation/modals, reset confirmations, fixture statistics, 16 language choices, dead-control signal scan, real Control sizes at seven resolutions and injected cutouts. Locale core navigation strings now machine-drafted in all 16; remaining strings still explicit English staging placeholders until Phase 8. Initial 149-image review capture succeeded with real OpenGL. Locally inspected Home, dense board and tutorial; fixed date-pattern source parsing, icon buttons, score digit spacing and tutorial footer/tray overlap before regenerating.

Phase-order discrepancy: Gate 6 references settings audio/FX behaviour which is implemented by Phase 7's explicit audio/FX gate. Phase 6 verifies real bus/state/theme/geometry effects; sound asset playback, full haptic patterns and particle/reduced-motion checks are deferred to Phase 7 and are NOT RUN. This is not a final U-08/A-03/A-04 PASS. Human review pack explicitly discloses current staging. Font coverage remains BLOCKED(font), the VRAM mipmap budget remains unresolved, and no visual/audio/native review is PASS.

Next 3 actions: complete final parser/core/desktop UI checks and regenerate the review pack; add cube-state and 16-locale contact sheets plus measured colour values to its index; request Human Design Review #1 and wait for the user's approval/change list before dependent visual work. No new permission is needed for remaining local implementation; physical device actions remain forbidden until explicitly authorized.

## Human Design Review #1 checkpoint â€” ready for user

Final executed results: parser exit 0 with no SCRIPT ERROR/Parse Error; `phase6-final-core` exit 0, last line `30963 checks, 0 failures`; real NVIDIA MX130 OpenGL `phase6-final-ui` exit 0, last line `UI: 1953 checks, 0 failures`. UI bot: `200 moves, 8 games`. Most recent repeated 64-cell draw maximum 111 microseconds, zero five-second idle invalidations, no Resource growth. Review capture exit 0: `Review capture: 158 files`; contact-sheet exit 0, 780x1688. Windows certificate/system-directory environment messages remain visible; no script error is accepted. Evidence: `build/evidence/phase6-final-*`, `phase6-review-capture.*`, `phase6-contact.*`.

Reviewable result: `docs/review/REVIEW_PACK_1/index.md`, 158 screen captures plus the 45-state cube sheet and 16-locale contact sheet (160 PNG artifacts total), seven viewport sizes, text-scale 1.15 cases and colour metrics. Locally inspected Home at 390/360, dense board, result modal, tutorial and contact sheet; no human approval or golden set claimed. V-07 stays BLOCKED awaiting the user's written approval/change list. Font failure, staged translations/audio/FX and mipmap memory discrepancy are disclosed prominently in the pack.

Additional correctness refinements covered by final runs: current best updates during active games; perfect clears accumulate exactly once; completed daily attempts retain their local mission date and active attempts appear in the daily count; current streak displays reset across missed days; previous-day active daily exits the playable view on rollover; tutorial has no unsafe Pause action and reserves footer space; Game Over Back returns Home; future-schema save rejection clears stale success state and disables destructive reset. About uses BuildInfo.VERSION_CODE=1 matching the still-current export preset, not a fabricated new APK code.

Gate disposition: Phase 3/4/5 automated gates passed; Phase 6 screen/control/layout automated checks pass. U-08's complete audio/haptic/FX observability remains Phase 7 because of the explicit implementation-order dependency documented above. Full visual acceptance is intentionally not PASS. Stop here for the explicitly requested Human Design Review #1. After approval/change resolution, proceed to Phase 7, Phase 8/Review #2, then Phase 9/10. Do not stop again at ordinary phase boundaries and do not run device commands without explicit authorization.

Checkpoint source/docs and timestamp/file list: `_archive/checkpoints/phase_6/` (Git metadata remains read-only). Resume by reading this file and the acceptance matrix, then use the user's review response. If no response exists, approval is still pending; do not infer it.

## Phase 0

- Archived original main.gd, main.tscn and previous acceptance matrix under `_archive/v0.1.0_prototype/` before editing production code.

- Verified engine 4.7.2.stable.official.ed1daf0bf and Temurin 17.0.21. SDK platforms android-35 and android-37.0; build-tools 35.0.0 and 37.0.0 are present. No device action executed.

- Baseline parser exit 0, no script parser errors; baseline test_core exit 0, last test line: `LumiBlock core tests passed`. These are baseline observations, not acceptance results. Root-certificate-store warnings occur in the sandbox. Evidence: `build/evidence/baseline-*`.

- Helpers redirect APPDATA, LOCALAPPDATA, USERPROFILE, TEMP and Android user directories inside the project. Actual player saves outside the workspace are not accessed.

- Preserved all design files and translation resources. Matrix initialized from every acceptance row with NOT RUN.

- User approved com.perih.lumiblock, to apply only in Phase 10 after manifest checks. No privacy URL: R-04 BLOCKED(user), URL row must be hidden. Official Manrope/Noto font downloads authorized; fallback to default and BLOCKED(font) if unavailable.

## Current work / next three actions

1. Present `docs/review/REVIEW_PACK_1/index.md` and obtain Human Design Review #1 approval or specific changes. Do not infer approval from elapsed time.

2. Apply any requested visual changes and regenerate affected screenshots. Then continue Phase 7 generated audio, full haptic patterns, effects and corresponding settings/reduced-motion tests.

3. Continue Phase 8 complete machine-drafted translations/formatters/pseudo-locale and font coverage (fonts currently BLOCKED), prepare Review #2, then Phase 9 hardening and Phase 10 Android checks. Device actions still require explicit approval with commands.

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

## Historical remaining scope at the Phase 2 checkpoint (superseded by resumed work above)

Phases 3â€“10 remain NOT RUN, including the Control-based AppRoot/screens/router/components, Tokens/ThemeFactory, atlas baking/rendering, DragController/UI event tests, real daily/statistics/settings/tutorial screens, all effects/audio/haptics, complete translations/font coverage, visual review packs, lifecycle/performance hardening and Android/release exports. The build and screenshot helpers deliberately report NOT RUN until their implementations exist. The old APK in build is not a new result. Native UI still uses prototype geometry and has known remaining audit findings; pure resolver/session tests do not establish final touch feel.

User decisions remain: official font downloads approved but not yet attempted; package com.perih.lumiblock approved only for Phase 10 after manifest checks; privacy URL absent, R-04 BLOCKED(user). Device actions have not been authorized or executed this session. No keystore creation, upload or package-ID modification occurred.

Exact next 3 actions:

1. Start Phase 3: probe the remaining Control/router/theme APIs and implement Tokens, ThemeFactory, components, AppRoot and ScreenRouter; point main_scene to AppRoot only after its boot test passes.

2. Implement Settings/Localization services and font fallback chains; attempt only approved official fonts with OFL files, keeping all writes inside the project; implement English keys and 16 translation registrations/checks.

3. Run Phase 3 boot/router/localization gates. Proceed to Phase 4 atlas and BoardView only when those gates pass. Preserve existing translation resources and design archive.

Resume: read this file, ACCEPTANCE_MATRIX.md, API_NOTES.md, and MASTER_IMPLEMENTATION_PROMPT.md section list, then `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1`. No permission question is needed to continue the authorized implementation.

### Final Phase 2 checkpoint evidence

Final parser exit 0, no SCRIPT ERROR/Parse Error. Final `run_all.gd` exit 0, last summary line exactly: `26329 checks, 0 failures`. Evidence: `build/evidence/run-all.stdout`, `run-all.stderr`, `parser.stdout`, `parser.stderr`; immutable copies under `build/evidence/phase2-final-*`. S-01â€“S-07 PASS at the domain/persistence gate; S-08 lifecycle remains NOT RUN. Persisted finished-session reopening was exercised through SaveService plus a new StatsTracker and did not recount; actual replacement Game Over UI remains U-04 NOT RUN. Session and piece extension fields survive GameSession serialization as well as raw profile saves.

Checkpoint copied to `_archive/checkpoints/phase_2/` with timestamp and source-file list. Historical reports are clearly labelled and original reports retained under `_archive/v0.1.0_prototype/docs/`; TEST_REPORT.md now describes only this session. Remaining phases have not been silently removed or mislabeled as blocked. The current code is tested, but the requested full redesign is incomplete.

## Constraints and status interpretation

The request initially says exactly three statuses, but later sections 16/18 explicitly require NOT RUN for initial/unexecuted work. The later, specific rule wins. Visual, audio and native translation review remain BLOCKED until reviewed. Physical device actions require a fresh explicit approval listing commands.

### Phase 7 task: audio assets and service wiring

Executed the original PCM16/32 kHz mono synthesizer: all 21 WAV files written, zero failures (build/evidence/phase7-synthesis.*). Initial peak tests found fade-after-normalization attenuated short ticks; moved fades before normalization and regenerated. Music import is set to IMA-ADPCM/forward loop; eight SFX voices, music lifecycle handling, real settings samples and throttled queued haptic patterns are implemented. Structural and reduced-motion tests are running; listening and physical feel remain BLOCKED(human). FxController/manual pooled sparks, settle/clear/popup/ring/chips, pickup/return, screen/button/score motion and Home glow are implemented and cancellable. No audio quality PASS is claimed.

Phase 7 completed task: original audio regenerated twice with matching SHA-256 for all 21 WAVs. Evidence: build/evidence/audio-determinism.txt and phase7-audio-repro.*. PCM16 mono/32kHz peaks are normalized after fades; source music is 48s, imported IMA-ADPCM. Human listening remains BLOCKED; no external samples or dependencies added.

Phase 7 completed task: audio/haptic/FX wiring tests report UI: 1973 checks, 0 failures; core structural suite reports 31127 checks, 0 failures. Real player playback, 8-voice pool, IMA looping, mute/sample/lifecycle behaviour, injected haptic clock/driver patterns and reduce-motion/minimal/rich particles were executed. Initial exit leaks were two playing AudioStreamWAV playbacks; stop_all clears streams and allows 100ms audio-thread drain, and rerun has no leak warning. Home breathing, tutorial guide, score tick, pickup/return, clears/sparks/popups/combo/perfect/record, modal/cancel and daily completion ring are implemented. Final parser/UI confirmation is running before Phase 8. Listening and physical vibration feel remain BLOCKED; no phone command has yet run.

Phase 7 gate: parser exit 0; core audio/format/loop tests: 31127 checks, 0 failures; UI audio/haptic/reduce-motion tests: UI: 1973 checks, 0 failures, exit 0. Audio SHA-256 repro passes for all 21 files. SFX now import PCM16 losslessly; music imports IMA-ADPCM. A-01/A-02/A-03/A-04 and V-10 automated behaviour checks pass. A-05 listening and real vibration feel remain BLOCKED. An engine shutdown warning still retains two AudioStreamWAV playback references even after explicit stop/free/drain; no script error occurs, and this is carried into Phase 9 resource hardening, not reported as a clean memory result. Phase 8 now begins without a review stop, as authorized. Decisions: retain approved art direction; use master effect durations/reduced-motion overrides; retain explicit font fallback when official downloads fail.

Phase 8 completed task: all 135 English source keys now have machine-drafted content in all 16 locale columns, including rules, privacy, errors, tutorial, settings, month names and placeholders. tools/complete_localization.py validates each locale vector's width before writing. Shared labels are deliberately aliased consistently. Native review remains BLOCKED(user); no quality sign-off is claimed. Next: run imports/placeholder checks, repair locale-specific formatting, pseudo-locale overflow and capture the waived Review #2 pack. Font files remain unavailable under the master fallback rule.

Phase 8 completed task: formatter and pseudo/RTL implementation validated. Core: 31163 checks, 0 failures (font coverage explicitly BLOCKED, not a fake PASS). Desktop UI: UI: 1993 checks, 0 failures; real desktop audio players exercised and no shutdown resource warning. Headless mode now correctly treats absent audio hardware as no-op and uses an explicitly injected driver for audio wiring tests; it does not claim audible playback. Pseudo locale reads the debug English CSV because OptimizedTranslation cannot enumerate source keys. Arabic numeric digit cells remain LTR, gameplay geometry is unchanged, live HUD text updates, and Back artwork mirrors. Review #2 capture is running without an approval stop; full native review and font coverage remain BLOCKED.

Phase 8 task: translated formatter/core run exited 0 (31163 checks, 0 failures); pseudo/RTL UI checks pass apart from an adjusted no-device music assertion, fixed by testing lifecycle state plus real-player pause only on desktop. Pack #2 capture exposed missing test-helper global class-cache entries while another Godot editor is open. Replaced global helper assumptions with explicit preloads in test/tool scripts; production model class names stay unchanged. The failed capture is recorded and is being rerun; no screenshot result is claimed from that failed attempt.

Phase 8 completed task: font blocker resolved safely. Manrope and all six Noto families now bundle official OFL licences. Auto-review rejected the custom text= subset request because it would disclose project characters; safer public CSS/Unicode-range downloads send no project text and were approved. Public shards are selected locally, total font source about 2.3 MB, no fontTools dependency installed. First bulk import crashed (-1073741819); clean retry exited 0. Full glyph run: 62555 checks, 0 failures, Blocked suites: 0. Manrope tnum verified from actual GSUB/GPOS tables. Bundled per-locale chains and variable weights now used. Updating screenshots/tests with these fonts; native review remains BLOCKED(user).

2026-11-15 resumed task: parser/core/UI all exit 0; core 62555 checks, 0 failures; UI 2001 checks, 0 failures. Evidence resume-nov15-*. Added optional injected classic seed and fixed capture date; Review 2 captures settle modal opacity/counting and use reduce motion for reproducible evidence. Production seed remains system-derived. Review 2 waiver remains active.

Phase 8 gate complete: settled Review 2 capture exit 0 (206 screens), contact sheet exit 0; cube-state sheet and measured contrast/colour numbers included. Machine drafts complete; glyph coverage all characters PASS. Review 1 approved, Review 2 waived. Native review and human listening remain BLOCKED(user). Phase 9: adding debug-only opt-in overlay and 50-game real-UI rich-effects stress harness; no release UI diagnostics by default.

Phase 9 task: expanded capture fixtures to Home Continue, mid-board, fixed-time clear effect, filled Stats, three daily templates x new/progress/done and daily done/failed results at all seven sizes. Optional --actual output supports repeat capture. Golden authority is Review 1 approval plus explicit Review 2 waiver; this establishes a regression baseline, not native-language/audio/phone sign-off. Comparator enforces channel tolerance 3 and max 0.5 percent differing pixels.

Phase 9 task PASS: real desktop OpenGL stress exits 0, 50 games plus warmup, 1840 real drag moves, rich effects, zero orphans at all checkpoints, stable 52 nodes/105 resources, static growth 272124 bytes. build/evidence/stress-ui.json contains all samples and frame percentiles. Bot computation contributes frame cost; these are not phone FPS measurements. Opt-in --perf-overlay is debug-only. Added .gdignore for generated evidence/archive directories to prevent pointless screenshot import churn.

Phase 9 task: reconciled ARCHITECTURE, LOCALIZATION, DESIGN_SYSTEM, PROGRESS and AUDIT_REPORT with current runtime; original reports preserved in prototype archive. Legacy main scene/script retained solely as protected compatibility source and will be excluded from exports. Capture isolation now resets stale SaveService notification/pending state; fixture save failures are reported as engine errors instead of silently appearing in screenshots.

Phase 9 regression first attempt correctly failed: 339 images, 106 differences over tolerance (exit 1). Root causes are capture fixtures resetting settings without persisting reduce-motion and a stale startup toast plus time-varying tutorial clear FX. Fixed capture settings/profile synchronization, isolated initial notices and settled FX; tolerance is unchanged. Regenerating baseline and independently repeating; no regression PASS yet.

Phase 9 correctness task: independently reproduced Godot JSON fractional-time checksum failure at elapsed 0.10000000000000021 (probe exit 1). Fixed verification: retain canonical semantic checksum first, then verify exact root data JSON bytes against the same SHA-256 for parser ULP drift; no rounding of save/session/RNG data, no checksum bypass. Added root-key/escaped-string/tamper and 120 tick/disk-roundtrip regression tests. Capture now exits 1 on fixture save failure; previous captures with failure toasts are not accepted. Running full gates and fresh clean captures.

Phase 9 task PASS: 10000 fractional-time round trips now pass (probe exit 0). Full core is 62929 checks, 0 failures including new timed-save/tamper/escaped-key regression. Expanded locale capture to Home/Settings/Game/GameOver across all16 at four required sizes; added actual About licence text captures. Repeating captures after full gates.

Phase 9 refinement: raw-byte checksum fallback additionally parses extracted bytes and requires equality to the parser's actual root data object, preventing duplicate-root-key ambiguity. Added a negative duplicate-key regression. No unknown-field rounding introduced. Previous complete parser/core/UI all exited 0; board redraw max206us, zero idle invalidations. New test rerun follows.

Phase 9 task: complete clean capture exits 0, 538 screens (16 locales at four sizes + seven-size fixtures + licences). No fixture save failure. Core checksum hardening final:62930 checks,0 failures,exit0. Golden source copied only after user-approved direction/waived second review; repeating independent run now. API probe first crashed when creating export preset before editor initialized; deferred retry returned166 real option descriptors including Export APK,Export AAB enum(1), arm64 and permission/icon keys. Probe teardown leaks are editor-probe-only, not runtime stress evidence. No splash export property exists in this engine-created Android preset; use actual project boot splash settings in Phase10.

Phase9 task: TEST_REPORT and tests/README now document current executed counts, stress scope, original failed regression, JSON drift repair and remaining human/spec limitations. Awaiting independent 538-image regression; no tolerance increase. Remaining Android release/device work is not yet claimed.

Phase9 gate PASS: final parser0; core62930/0; UI2001/0; desktop rich-effects stress50games+warmup1840moves,zero orphans/stable resources; independent538-image screenshot regression0failures(exit0),channel tolerance3,0.5percent. Docs reconciled. V-06 PASS; P-04 desktop PASS with phone portion blocked. Phase10 now starts. Next: preset/icons/debug export; initial manifest then approved package change/reverification; only authorized device commands and final release docs.

Phase10 task: copied installed official Android templates and existing DEBUG keystore to ignored project-local runtime directories (no production key read/created). Configured Java17/SDK paths locally, Debug arm64/VIBRATE/noINTERNET filters and blank-credential Gradle AAB preset. Version0.2.0/code2 coordinated with BuildInfo. Package remains com.example until initial manifest passes. Added original vector-rendered icon layers and verified project boot-splash configuration tool; no Android splash preset key exists in the probed engine.

Phase10 manifest task PASS: initial com.example build target36,arm64,portrait,VIBRATE only; aapt xmltree confirms MAIN/LAUNCHER alias com.godot.game.GodotAppLauncher. Initial badging omits aliases. After these checks applied approved com.perih.lumiblock to both presets. First APK34623127bytes exceeds32MB. Original network-restricted pip attempt failed; approved escalation installed build-only fontTools4.68.0/Brotli1.2.1 under ignored .runtime. Local-only subsetting sends no project text; original official shards archived, modified fonts renamed,all GSUB/GPOS layout retained,OFLs intact. Reverify coverage/UI and size next.

Phase10 font task: local Noto subsets2147656 ->501348bytes; full Manrope retained,all original OFLs retained,modified family names applied. Build tools remain ignored; restrictive pip temp ACLs were reset only on the newly installed dependency subtree after auto-approved escalation. Size budget decision: use PowerShell32MB=33554432bytes(32MiB),record exact bytes and MiB,do not call it32million bytes. Final build helper enforces that value. Android Gradle template installed automatically on first final export; release signing still blocked by absent user key.

Phase10 import task: first bulk subset-font import crashed Godot -1073741819 near JP028,matching the prior full-font bulk importer issue. No APK from this failed gate is accepted. Saved crash output separately; clean retry follows. Do not kill unrelated existing user editor processes.

Phase10 documentation task: wrote KEYSTORE_GUIDE with user-only key generation and officially verified environment overrides; DATA_SAFETY/STORE_LISTING/content-rating drafts reflect offline implemented features; DEVICE_CHECKLIST has all human items unchecked. Reconciled FONTS and font README with local subsetting/provenance,earlier rejected text-upload alternative and preserved OFLs. No production key touched,no publishing.

Phase10 APK task PASS: clean retry parser/export exit0; final APK33039259bytes(31.5087MiB),SHA256 a6bc52f87f8ba8dafc1597acd8a26569a60d571e37425f43e2883ee9103ae3d5. Final read-only verification all exit0:approved com.perih,API36,arm64,portrait,VIBRATE only,v2/v3 signatures,exclude filters,sevenOFL files,font manifest,zipalign16KB and both ELF PT_LOAD alignments16384. Gradle template4.7.2 installed locally; AAB signing remains BLOCKED(user key). Export warns about potentially mismatched ICU versions; editor/templates both4.7.2 verified,phone/runtime evidence still required. Export/editor teardown reports one ObjectDB warning; runtime stress remains zero orphans. Device commands next under standing exact authorization.

Phase10 device task: sandbox adb exited3221226505; auto-approved escalation ran only the authorized devices/install-r/verified-alias start/screencap/gfxinfo/meminfo/logcat commands with project-local Android home. All exit0; installSuccess; app launched Adreno618. Screencap transport inserted CR before LF; reversed transport escaping locally and verified every PNG chunk CRC,raw bytes retained. App-PID-scoped log extracted; no unrelated system crash attributed to app. First-install Displayed3s154ms exceeds2s target; this is NOT a startup PASS. Passive25frames4percentjank and227580KiB PSS do not establish3minplay/10game trends. Manual lifecycle/feel/cold-restart remain blocked by interaction/command scope.

Phase10 post-subset regression:538images,5failures (exit1). Four Thai Home captures shifted after fontTools recomputed global font bounds; preserve original bounding metrics and timestamps when subsetting. Fifth Settings-bottom capture raced deferred scroll geometry; settle and reapply scrolling across four frames. No golden/tolerance change used to hide failures. Rebuilding/rechecking actual assets. Phone follow-up passive screenshot confirms Turkish Home; no app-PID script/parse/fatal error in short launch window. First splash image is retained separately from actual Home screenshot.

Phase10 layout task: Home brand fitting now uses actual ScrollContainer height,so phone cutout/safe margins are included rather than subtracting only generic margins. Added debug-only safe-area value logging on actual mobile geometry changes for authorized logcat evidence. No diagnostic appears in release UI. Re-run desktop layout/input suite and recapture after this real-device-driven refinement.

Phase10 validation task: strengthened desktop lifecycle test to replace AppRoot and restore exact saved board,three tray slots,u32 stream state and score after pause flush. Native device lifecycle still requires manual interaction; this test does not fake Android kill/Back coverage.

Phase10 release documentation task: ANDROID_TEST_REPORT now records exact current APK33039482bytes/SHA8394d54005c7f509e763ee49cdb8d2e780babd0fce2e0e4888c45d87902bd689 and all executed host checks; RELEASE/RELEASE_CHECKLIST reconcile package/version/icon/licence/signing/store/account/manual blockers. Added android/build to ignore rules; official Gradle template remains local. Final core/UI/render regression and updated-device collection running.

Phase10 regression refinement: scroll fixture now passes; only four Thai Home pixel regressions remain(1.9–2.5percent due shifted text). Retain both original official Thai shards instead of modified subsets,adding24048bytes; budget remains below32MiB. Script now preserves Thai originals and subsets other families. No golden/tolerance change. Device Home fits actual safe area; logged raw(0,102,1080,2298),viewport390x866. Updated Activity Displayed1.603s precedes mainloop,so it is not sufficient gameplay-first-frame evidence; first-install3.154s miss remains documented. Cold/release startup profiling needs user/manual/production setup; not claimed PASS.

Phase10 matrix task: Android/release rows now carry executed PASS evidence or concrete BLOCKED reasons;no future NOT RUN rows remain. V06 temporarily FAIL pending final Thai-restoration diff. Manual OS/feel/audio/native/store/key/URL/account remain BLOCKED. X01 records atlas memory conflict. Native Activity Displayed is not gameplay first-frame proof. Normalized progress file to UTF8 BOM so Windows PowerShell appends preserve Unicode.

## Final Phase10 checkpoint ? 2026-11-15

Final parser/export exits0; core62930checks/0failures/0blocked suites,exit0; real desktop UI2005checks/0failures,exit0; final538captures/538-image regression0failures,exit0. Evidence done-{core,ui,capture,diff}.*,android-build-parser.*,android-debug-export.*. Original golden/tolerance unchanged. Desktop50-game+warmup rich-effects stress1840moves,zeroorphans,stable52nodes/105resources,272124-byte growth. Final board max247us;zero5second idle invalidations.

Final debugAPK33064058bytes(31.5323MiB),SHA256bb1db99a7132d4b802f67b6024ab152cbea997bd3fd05f7c58a8813e2f979ef7. Approved com.perih.lumiblock only after initial manifest checks;0.2.0/code2;API36;portrait;arm64;VIBRATE/noINTERNET;v2/v3;16KB ZIP and ELF;filters and7OFL files allverified. Existing debug key only. Final APK installed/launched via exact authorized commands;all exit0. Actual Home and safe-area logs captured;currentPID7263,noapp script/parse/fatal in short window. Native display1.242s is not gameplay-start qualification;first-install3.154s miss retained.

Remaining BLOCKED reasons: manual phone thumb/latency/Back/lifecycle/10-game memory/3-minute FPS/20-minute crash/thermal/all-screen cutout checks; real vibration and human audio listening; Arabic joining/native translations;production keystore/signedAAB;hosted privacy URL;Play identity/account;feature graphic/approved phone store set;first-gameplay-frame/cold/release startup qualification (first-install target missed); required RGBA8+mips approx2MiB conflicts with1.6MiB budget. No production key created/read,no upload,no emulator,no unauthorized input/kill/force-stop/uninstall/clear/pull.

Resume commands for future code changes: powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_debug.ps1; dot tools/environment.ps1 then Invoke-GodotChecked for --headless --script res://tests/run_all.gd and desktop res://tests/ui_runner.tscn. Review captures --actual and compare_screens.gd guard existing approved golden. Device commands stay limited to the user's exact standing list. Current unblocked work is complete;no new ordinary approval gate is introduced.

Final documentation audit: repaired stale localization/REVIEW font blocker (coverage is resolved),normalized progress encoding/extra blank lines,and included .gitignore in source checkpoint copies. All93 master matrix IDs plus explicit X01 are present;final status audit and phase10 checkpoint follow.

Final audit PASS:all93master IDs plusX01 present;73PASS/21BLOCKED;zeroFAIL/NOT RUN rows;every evidence link resolves;installed APK SHA matches final file;all authorized device commands exit0. done-parser exit0,no script/parse errors;core62930/0,UI2005/0,538-image diff0failures. Audit:build/evidence/final-audit.json. Phase10 source/docs checkpoint:_archive/checkpoints/phase_10/. Stop condition reached through explicit BLOCKED disposition;no unblocked implementation task remains.

## Real-phone touch bug - reproduction BEFORE fix

Added tests/ui/test_touch_pipeline.gd using Input.parse_input_event(ScreenTouch/ScreenDrag,index0),real viewport GUI dispatch,no Control methods/signals. Added optional --suite filtering to UI runner (zero matching suites fails). Original emulate_mouse_from_touch=false retained during reproduction. Parser exit0;touch-repro UI exit1:5checks,4failures. Actual Settings scroll0->0;Stats0->0;SFX0.8->0.8;music0.6->0.6. Evidence build/evidence/touch-repro.*. U15/U16 and U08 are FAIL before any fix. Existing direct-signal UI tests missed this real-input path. Next: enable emulation,verify child routing and horizontal-slider gesture ownership;expand real-input regressions;full gates/build/authorized install.

Touch repair task: emulate_mouse_from_touch=true alone fixed Settings/slider but Stats cards blocked propagation. LBCard/LBButton/LBToggle now PASS;passive labels IGNORE;LBSlider explicitly STOP with existing48dp minimum. Expanded viewport tests caught toggle/picker blocking,then Home daily card navigating on pan. Card now navigates only on completed mouse/emulated-mouse tap,excludes child buttons,and cancels on pan/scroll. Existing Home test converted from raw gui_input emission to viewport touch. Touch-index-only DragController guard was already correct and is preserved/documented.

Targeted viewport regression passed58checks/0failures(exit0),including disk-persisted sliders/intermediate values/4px vertical jitter,card+label+toggle scroll,picker+licence scroll,segments,one native-touch drop with second-finger ownership,and one physical-mouse-emulated touch drop. Initial synthetic physical mouse test omitted global_position,causing one ghost assertion failure;populating both real event coordinates fixed it. No golden/tolerance or production resolver change. Added stat-label filter check next. Version bumped0.2.1/code3 so the repaired phone build is identifiable;save envelope uses current application version,and APK verifier checks presets/project/BuildInfo consistently.

Touch regression task PASS:extended real-input suite70checks/0failures,exit0(touch-modal-regression). Includes Pause Settings modal scroll/volume,unchanged underlying gameplay,real Back/Resume/Confirm Cancel,Game Over fitting/pan handling,card padding,label/toggle/picker/About scroll,text-size/effects taps,slider intermediate+persisted values,vertical jitter and exactly-one touch/mouse drops. Full parser/core already exit0;62930core checks/0failures. Previous full UI2064checks/0failures included existing I01-I07 cancellation/multitouch/bot tests. Re-running full UI after modal-test extension,then building0.2.1/code3 and authorized install.

Touch full verification task PASS:parser exit0;run_all62930checks/0failures,exit0;full desktopUI2075checks/0failures,exit0(touch-full-ui). Existing drag cancellation,multitouch,empty-slot,preview/release and200-move bot suites pass alongside the native/desktop viewport pipeline. Debug build0.2.1/code3 exits0,size33068154bytes;host APK re-verification and authorized install next. No physical touch injection is authorized/performed;phone gesture retest remains for user.

Touch APK/device task:host manifest/signature/filter/16KB verification all exit0;0.2.1/code3,33068154bytes(31.53625MiB),SHAb0801228537b3186ec8a650082890ec882e86aa121c89ea36d9af91254038ecc. Authorized install-r exit0(Success),manifest-proven launch exit0. USB dropped before screenshot/gfxinfo/meminfo(each exit1,no device);logcat reconnected and exited0. Preserve failed passive reads;retry only authorized read commands. No phone touch injection/clear/uninstall used.

Touch device/read completion PASS:retry devices,screencap,gfxinfo,meminfo,logcat all exit0 after transient USB loss. Install/launch remained exit0. CurrentPID12992,noapp script/parse/fatal;Home screenshot retains real best5870. status.json preserves initial failed read attempts. Updated release/test/Android reports and manual retest checklist to0.2.1/code3. No physical gesture PASS is claimed;user re-test requested. Exact source changes verified by hash comparison with phase10 checkpoint. Final touch audit/source checkpoint next.

Touch final audit PASS:24intentional source/config/test/doc files match phase10 hash comparison;all evidence links valid;U08/U15/U16 andI01-I07 PASS. Matrix75PASS/21pre-existingBLOCKED,noFAIL/NOT RUN. Reproduction exit1/four failures retained;final parser/core/UI/build/install/launch all exit0,core62930/0,UI2075/0. APK33068154bytes(31.536249MiB),SHAb0801228537b3186ec8a650082890ec882e86aa121c89ea36d9af91254038ecc. Failed USB passive-read attempt retained,retries0. Audit:build/evidence/touch-final-audit.json. Snapshot:_archive/checkpoints/touch_fix_0.2.1/. User re-test list:docs/DEVICE_CHECKLIST.md;exact file list:docs/TOUCH_INPUT_FIX.md. No remaining unblocked repair task.
