# LumiBlock implementation progress

2026-11-14, Europe/Istanbul. Authoritative request: MASTER_IMPLEMENTATION_PROMPT.md.

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

## Constraints and status interpretation

The request initially says exactly three statuses, but later sections 16/18 explicitly require NOT RUN for initial/unexecuted work. The later, specific rule wins. Visual, audio and native translation review remain BLOCKED until reviewed. Physical device actions require a fresh explicit approval listing commands.
