# Acceptance matrix

Current-session results only. NOT RUN is the initial state; historical reports are not evidence for this implementation.

| ID | Item | Method | PASS criterion | Auto/Man | Status | Evidence |
|---|---|---|---|---|---|---|
| C-01 | Atomic placement | `unit/test_board.gd` invalid placement leaves board identical | board dict equal before/after; valid returns `valid=true` | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-02 | Row/column clear counting | `unit/test_board_clear.gd`: row, col, row+col cross, 2 rows+1 col, 8 rows | `lines == rows+cols` in every case; cross of 1 row+1 col = 2 lines, 15 cells | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-03 | Catalog integrity | `unit/test_catalog.gd` | 37 unique ids; all connected, normalized, no duplicates; the 10 v1 shapes present | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-04 | PRNG determinism | `unit/test_seeded_rng.gd` fixed-seed vectors | exact expected sequence; state < 2³²; JSON round-trip lossless | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-05 | Generator fairness | `unit/test_generator.gd` 5,000 trays on random boards | ≥ 1 placeable piece in 100% of classic trays; no triple identical id; colour rule holds | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-06 | Generator distribution | same | size buckets within ±3 pts of weights over 20,000 pieces (neutral board) | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-07 | Scoring table | `unit/test_scoring.gd` n=0..5 × s=0..8, perfect, grace | matches spec formulas exactly | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-08 | Session game-over | `integration/test_session_gameover.gd` | game over fires only when no tray piece fits; re-evaluated on restore | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-09 | Full bot game | `integration/test_bot_game.gd` 200 seeded games | no errors; score monotone; every game ends; stats consistent | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-10 | Balance report | `tools/sim_balance.gd` → `docs/BALANCE_REPORT.md` | report exists; first-level guarantee failures = 0 | Auto | PASS | `../build/evidence/run-all.stdout`; C-10: `BALANCE_REPORT.md`, `../build/evidence/balance.stdout` |
| C-11 | Daily determinism | `unit/test_daily.gd` | same date → same board + first 30 pieces; 366 leap-year days valid | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| C-12 | Daily completion | `integration/test_daily_flow.gd` | completed/failed/expired transitions; replay never alters completion/streak; streak across month/year | Auto | PASS | `../build/evidence/run-all.stdout`; C-10: `BALANCE_REPORT.md`, `../build/evidence/balance.stdout` |
| S-01 | v2 round trip | `integration/test_save_roundtrip.gd` | save→load equals original incl. sessions, history, settings | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-02 | v1 migration | `integration/test_save_migration.gd` with all `save_v1_*.json` fixtures | fields mapped per spec; `.v1.bak.json` created once; active sessions resumable | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-03 | Corruption recovery | truncated / garbage / wrong-type / checksum-mismatch files | quarantine file created; `.bak` used if valid; defaults otherwise; no crash; toast event emitted | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-04 | Future schema | `schema: 3` file | not overwritten; saving disabled; warning event | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-05 | Float/int coercion | v1 fixture with `3.0` values | every numeric field int where int; Stats UI shows `3` not `3.0` | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-06 | Atomic write failure | inject failing rename | old file intact; `save_failed` emitted | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-07 | Stats idempotency | finish session, reload, reopen game-over | stats counted once | Auto | PASS | `../build/evidence/run-all.stdout`; prototype integration/coercion/debounce: `../build/evidence/phase2-prototype-smoke.stdout`. S-07 covers persisted finished-session logic; final Game Over UI is U-04, NOT RUN. |
| S-08 | Lifecycle save | send `APPLICATION_PAUSED` mid-game | save written (timestamp changes); resume restores same board/tray/score | A+M | NOT RUN | — |
| I-01 | DropResolver math | `unit/test_drop_resolver.gd` | alignment, hysteresis, assist tie-break, clamp; preview == release for 1,000 random positions | Auto | PASS | `../build/evidence/run-all.stdout`, `tests/unit/test_drop_resolver.gd`: 3000 sampled preview/release comparisons and assist tie test. |
| I-02 | Single pointer owner | `ui/test_drag_multitouch.gd` synthetic 2 fingers | second finger ignored; owner end ends drag; no double drop | Auto | NOT RUN | — |
| I-03 | Empty-slot safety | touch empty slot after placing 1 piece | no capture, no error (F-01 regression) | Auto | NOT RUN | — |
| I-04 | Cancel paths | focus-out, pause, back, resize, 2 s timeout | piece returns, board/tray/score unchanged | Auto | NOT RUN | — |
| I-05 | Invalid drop | drop outside / overlapping | piece returns; board unchanged; piece never lost | Auto | NOT RUN | — |
| I-06 | Fast flick | single huge `ScreenDrag` jump | final resolve correct; no exception | Auto | NOT RUN | — |
| I-07 | Visual = logical | screenshot at drop moment vs placed result | ghost cells == placed cells (programmatic compare of cell sets) | Auto | NOT RUN | — |
| I-08 | Finger occlusion feel | hold piece with thumb on device; board cells under piece visible | piece bottom edge ≥ 0.9 cell above touch point; ghost fully visible | Man | NOT RUN | — |
| I-09 | Latency/feel | 10-minute play on device | no jump, no lag, no mis-drops reported by user | Man | NOT RUN | — |
| I-10 | Android back | back at each screen | per 6.2 matrix; app never exits except from Home | A+M | NOT RUN | — |
| U-01 | Home | `ui/test_home.gd` + screenshots | all buttons present/working; Continue only with active session; best card correct | A+M | NOT RUN | — |
| U-02 | Game screen | `ui/test_game_screen.gd` | HUD updates from session signals; status row height constant; no dead controls | A+M | NOT RUN | — |
| U-03 | Pause | `ui/test_pause.gd` | resume/restart(confirm)/settings/menu behave; timers freeze | Auto | NOT RUN | — |
| U-04 | Game over (classic) | `ui/test_gameover.gd` | numbers match session; new-best badge logic; buttons work | Auto | NOT RUN | — |
| U-05 | Game over (daily) | same | completed/failed variants correct | Auto | NOT RUN | — |
| U-06 | Daily screen | `ui/test_daily_screen.gd` | status/progress/streak/attempts match save; midnight rollover handled | Auto | NOT RUN | — |
| U-07 | Statistics | `ui/test_stats_screen.gd` with fixture | every displayed number equals fixture; empty state works | Auto | NOT RUN | — |
| U-08 | Settings controls | `ui/test_settings.gd` | each control changes service state **and** observable behaviour (bus mute, haptics call counter, effects level, assist, marks, text scale) | Auto | NOT RUN | — |
| U-09 | Language picker | `ui/test_language.gd` | all 16 selectable; live relabel without restart; persists | Auto | NOT RUN | — |
| U-10 | Tutorial | `ui/test_tutorial.gd` | completes by scripted drag; skip sets flag; no stats impact | Auto | NOT RUN | — |
| U-11 | Navigation graph | `ui/test_router.gd` | every button leads where spec says; no orphan screen; transitions block double-tap | Auto | NOT RUN | — |
| U-12 | Dead-control scan | script walks scene trees | every `BaseButton`/`LB*` has a connected handler | Auto | NOT RUN | — |
| U-13 | Responsive layout | `unit/test_layout_metrics.gd` + screenshots at 7 sizes | no overlap/overflow; board square; tray fits; targets ≥ 48 dp | A+M | NOT RUN | Pure metrics PASS at all 7 sizes with injected insets; screenshots/UI remain NOT RUN. |
| U-14 | Safe area | layout test with injected cutouts + device log | content outside insets; values logged | A+M | NOT RUN | — |
| V-01 | Contrast | `unit/test_contrast.gd` | text pairs ≥ 4.5:1; cube vs socket ≥ 3:1; documented values reproduced | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| V-02 | Colour-blind separation | same | ΔE76 ≥ 20 for all pairs under normal/deut/prot | Auto | PASS | `../build/evidence/run-all.stdout` (executed core suite); colour values: `../build/evidence/palette-math.txt` |
| V-03 | Cube atlas | bake tool + `unit/test_atlas.gd` | file exists, 512×768, alpha edges anti-aliased, regenerated bytes identical | Auto | NOT RUN | — |
| V-04 | Cube states | `capture_screens.gd` renders every state | screenshots exist for 9 states × 5 families | Auto | NOT RUN | — |
| V-05 | Dense board legibility | screenshot with 56/64 cells filled | human confirms cubes separable & sockets distinct | Man | NOT RUN | — |
| V-06 | Screenshot regression | pixel diff vs golden (≤ 0.5% differing pixels) | all listed screens × 4 sizes | Auto | NOT RUN | — |
| V-07 | **Human design review** | user reviews screenshot pack (14.6) | written approval or change list | Man | NOT RUN | — |
| V-08 | Typography scale | UI test reads theme font sizes | match 10.2; no size < 12 dp | Auto | NOT RUN | — |
| V-09 | Text scale 1.15 | screenshots Home/Settings/Game Over | no clipping/overlap | A+M | NOT RUN | — |
| V-10 | Reduced motion | `ui/test_reduce_motion.gd` | zero running position/scale tweens, zero particles with RM on | Auto | NOT RUN | — |
| L-01 | CSV integrity | `unit/test_localization.gd` | 17 cells per row; keys unique; every key non-empty in 16 locales; placeholders equal | Auto | NOT RUN | — |
| L-02 | Keys used = keys defined | code scan | no missing keys; no hard-coded UI literals in `ui/` | Auto | NOT RUN | — |
| L-03 | Registration | project settings check | 16 `.translation` files registered; fallback `en` | Auto | NOT RUN | — |
| L-04 | Live switch | UI test sets each locale | visible strings change; no restart | Auto | NOT RUN | — |
| L-05 | Glyph coverage | `unit/test_font_coverage.gd` | every character in every translation exists in its locale font chain | Auto | NOT RUN | — |
| L-06 | RTL | screenshots `ar` for all screens | HUD mirrored; board/tray not mirrored; no broken joining | A+M | NOT RUN | — |
| L-07 | Formatters | `unit/test_locale_format.gd` | number/date/duration per locale table | Auto | NOT RUN | — |
| L-08 | Pseudo-locale overflow | UI scan with +40% strings | no clipped/overlapping controls | Auto | NOT RUN | — |
| L-09 | Translation quality | native review | reviewer sign-off | Man | NOT RUN | — |
| A-01 | Assets exist | file check | all events in 11.1 present, 16-bit mono, peaks −6/−9 dBFS ±1, no NaN/clip | Auto | NOT RUN | — |
| A-02 | Loop integrity | sample analysis | music head/tail delta < 0.02 at loop point | Auto | NOT RUN | — |
| A-03 | Settings wiring | test double for bus/player | toggles mute bus; volume maps; samples play | Auto | NOT RUN | — |
| A-04 | Haptics wiring | call-counter double | patterns as spec; throttled ≥ 40 ms; no-op when off/desktop; no errors | Auto | NOT RUN | — |
| A-05 | Audio quality | listening | user approval | Man | NOT RUN | — |
| A-06 | Real vibration | device | user feels pickup/place/clear; off toggle silences | Man | NOT RUN | — |
| P-01 | Idle redraw | profiler/frame counter | zero `queue_redraw` calls on `BoardView` while idle for 5 s | Auto | NOT RUN | — |
| P-02 | Board redraw cost | microbenchmark 64 filled cells | ≤ 1.5 ms (desktop proxy); device value recorded | A+M | NOT RUN | — |
| P-03 | Frame rate on device | `dumpsys gfxinfo` + manual | ≥ 55 fps average, janky frames < 5% during 3-min play incl. clears | A+M | NOT RUN | — |
| P-04 | Memory | `dumpsys meminfo` start vs after 10 games | no growth trend > 15 MB; no orphan nodes (`Performance.OBJECT_ORPHAN_NODE_COUNT` = 0 after screen cycles) | A+M | NOT RUN | — |
| P-05 | Startup time | logcat time-to-first-frame | ≤ 2.0 s cold start on the user's phone (record value) | A+M | NOT RUN | — |
| P-06 | Allocation churn | script counts new `Resource` instances per frame during play | 0 per frame in steady state | Auto | NOT RUN | — |
| N-01 | Debug APK builds | `tools/build_debug.ps1` | exit 0; file exists; size ≤ 32 MB | Auto | NOT RUN | — |
| N-02 | Manifest facts | `aapt dump badging/permissions` | package as approved; `targetSdkVersion 36`; **VIBRATE present; INTERNET absent**; portrait; arm64-v8a | Auto | NOT RUN | — |
| N-03 | Signature | `apksigner verify --verbose` | v2/v3 OK | Auto | NOT RUN | — |
| N-04 | Export filter | list APK entries | no `design/`, `docs/`, `tests/`, `_archive/`, `tools/` | Auto | NOT RUN | — |
| N-05 | 16 KB alignment | `zipalign -c -P 16 -v 4` (build-tools 35+) or ELF check | aligned | Auto | NOT RUN | — |
| N-06 | Install + launch | `adb install -r`, `am start` | app starts; first frame; no crash in `logcat` | Man | NOT RUN | — |
| N-07 | Lifecycle | home/recents/rotate-lock/kill/restore | state restores; no crash | Man | NOT RUN | — |
| N-08 | Safe area / notch | visual on device | no content under cutout/gesture bar | Man | NOT RUN | — |
| N-09 | Release AAB | gradle/GABE release preset | `.aab` produced with user keystore | Auto | NOT RUN | — |
| N-10 | Crash scan | `logcat -d` after 20-min play | no FATAL / Godot ERROR from our scripts | Man | NOT RUN | — |
| R-01 | Package ID | user approval | non-`com.example` id approved by user and applied | Man | NOT RUN | User approved com.perih.lumiblock; apply only in Phase 10 after manifest checks. |
| R-02 | Icon & splash | `render_icons.gd` + visual | adaptive icon layers present; splash uses `BG_0` | A+M | NOT RUN | — |
| R-03 | Store assets | screenshots, 512 icon, 1024×500 feature graphic | files present at correct sizes | A+M | NOT RUN | — |
| R-04 | Privacy policy URL | user hosts policy | URL live and matches in-app text | Man | BLOCKED | User: no hosted privacy-policy URL yet; URL row must stay hidden. |
| R-05 | Data Safety draft | `docs/DATA_SAFETY.md` | states: no data collected/shared, local storage only (valid only if N-02 shows no INTERNET) | A+M | NOT RUN | — |
| R-06 | Play account | identity verification | resolved by user | Man | NOT RUN | — |
| R-07 | Versioning | `version/code` increments, `version/name` semver | documented in `docs/RELEASE.md` | Auto | NOT RUN | — |
| R-08 | Licences | `assets/fonts/LICENSES`, in-app licences screen | all bundled third-party items listed | A+M | NOT RUN | — |
