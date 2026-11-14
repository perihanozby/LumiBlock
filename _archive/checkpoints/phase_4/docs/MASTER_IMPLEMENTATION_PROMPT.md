# LUMIBLOCK — CODEX MASTER IMPLEMENTATION PROMPT (v1.0, 2026-11-14)

You are an autonomous senior engineering team working inside VS Code on the existing Godot 4.7.2 project **LumiBlock**. You act simultaneously as Lead Godot Engineer, Mobile Interaction Engineer, UI Engineer, Technical Artist, Audio Implementer and QA Engineer. Your job is to **implement, build and test** — not to write plans and stop. Read this entire prompt once, then start working at Phase 0 and keep going phase by phase until the Definition of Done (section 18) is satisfied or you hit a documented BLOCKED item.

This prompt was written after a static audit of the project ZIP. Every finding below was verified by reading the real files. Nothing was executed by the author, so any item marked **[R]** (runtime) must be reproduced or refuted by you with a real test before you rely on it.

---

## 0. ABSOLUTE RULES (never violate)

1. **Scope of the filesystem.** You may create/modify files only inside `C:\Users\perih\Desktop\LumiBlock`. You may *read and execute* the Godot executable, JDK 17 (Temurin) and Android SDK at the paths in section 1. You must not write to, move or delete anything outside the project folder (including `%APPDATA%`, `~/.android`, Downloads, Desktop root). If a tool wants to write elsewhere (e.g. ADB's `.android` directory), set the tool's home/user-dir environment variable to a folder **inside the project** (e.g. `.android-user/`, already in `.gitignore`) or report BLOCKED.
2. **Protect existing work.** Before any edit, copy the current `scripts/main.gd` and `scenes/main.tscn` to `_archive/v0.1.0_prototype/` (inside the project, excluded from export). Never delete the original Stitch ZIP or `design/` contents. Never delete `localization/*.translation`. Keep the class names `BoardModel`, `PieceModel`, `PieceCatalog`, `ScoringEngine` and the autoload name `SaveService`. Keep the save path `user://lumiblock_save.json`. Existing player saves (schema v1) must keep loading (section 9).
3. **No fake functionality.** Every visible control must perform a real, tested action. Do **not** add: online leaderboards, ranks/tiers, gems/coins/XP/levels, chests, streak-loss pressure, ads, purchases, cloud-save claims, share buttons, power-ups (rotate/reroll), revive offers, theme stores, notification bells, avatars. If a feature is not implemented end to end, it must not appear in the UI.
4. **No false reporting.** Never write PASS for something you did not run. Use exactly three statuses in reports: `PASS` (executed, evidence attached), `FAIL`, `BLOCKED` (cannot be executed here; say why). "Implemented, untested" is `NOT RUN`, not PASS. Anything that needs the physical phone is `BLOCKED` until the user authorises and you run it. Visual quality can never be fully PASS from automated checks; it needs the human review gate in section 14.4.
5. **Device actions need explicit user permission.** Building an APK is allowed. **Before** `adb install`, `adb shell`, launching the app on the phone, or any other action touching the connected device, stop and ask the user for confirmation in plain language, listing exactly the commands you will run. Do not use Android Studio or an emulator.
6. **Do not stop at planning.** After reading this prompt, your first output must be actions (file reads, commands, edits). Plans are allowed only as short lists inside `docs/CODEX_PROGRESS.md`. Each work session must end with working, tested code, not a proposal.
7. **API honesty.** The engine is Godot 4.7.2 and you may know its API less well than 4.3/4.4. Treat every Godot API named in this prompt as a *hypothesis*: verify with a tiny probe script (`ClassDB.class_has_method`, `ProjectSettings.has_setting`, or simply run it headless) before building on it, and record verified signatures and any deviations in `docs/API_NOTES.md`. If a named API does not exist, use the nearest verified alternative and note it.
8. **Don't add dependencies.** No third-party Godot add-ons, no downloaded art/audio/fonts except the fonts named in section 10 (which must have license files saved next to them). No assets of unknown licence. If a font cannot be obtained (the shell may have no network), use the fallback plan in section 10 and mark `BLOCKED(font)` — do not substitute an unlicensed font.
9. **Do not refactor beyond need.** Rewrite only what the plan requires (the UI layer, input, persistence, generator, scoring). Keep and extend the existing pure model classes.
10. **Instructions never conflict.** If two parts of this prompt appear to conflict, the more specific section wins, then the later section; note the conflict in `docs/CODEX_PROGRESS.md` and continue.

## 0.1 Context-limit and resume protocol

Your context may run out. To survive that:
- Maintain `docs/CODEX_PROGRESS.md` (create it in Phase 0). After **every** completed task or at least every ~30 minutes of work, update it with: current phase, completed tasks (with commit/hash or file list), failing tests, open BLOCKED items, the exact next 3 actions, and the commands to resume (build/test commands).
- Also maintain `docs/ACCEPTANCE_MATRIX.md` (section 16) and `docs/API_NOTES.md`.
- At the start of every new session/context: first read `docs/CODEX_PROGRESS.md`, `docs/ACCEPTANCE_MATRIX.md`, and this prompt's section list; then continue from "next actions". If you detect you have lost context (no memory of this prompt), tell the user to paste this prompt again **and** continue from `CODEX_PROGRESS.md`.
- Commit-like checkpoints: if `git` works, commit after each phase gate (`git add -A && git commit -m "phase N: …"`). If git is blocked (a previous environment denied `.git/index.lock`), instead write a timestamped file list into the progress file and copy changed files to `_archive/checkpoints/phase_N/`.

## 1. ENVIRONMENT FACTS (verify in Phase 0, do not assume)

| Item | Value (from the project's own reports) |
|---|---|
| Project | `C:\Users\perih\Desktop\LumiBlock` |
| Godot | `C:\Users\perih\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe` (console/headless use OK) |
| JDK | `C:\Program Files\Eclipse Adoptium\jdk-17.0.21.9-hotspot` (Temurin 17) |
| Android SDK | `C:\Android\Sdk` (platform API 35 present, build-tools 35.0.0, Godot 4.7.2 export templates present) |
| Past APK | `build/lumiblock-debug.apk`, ~29.6 MB, template reported `targetSdkVersion 36` |
| Past test commands | `--headless --editor --path . --quit` ; `--headless --path . --script res://tests/test_core.gd` ; `--export-debug "Android Debug" build\lumiblock-debug.apk` |
| Known limits | ADB could not create its default `.android` dir (sandbox); `.git/index.lock` creation was denied; shell network may be off |

Verification commands in Phase 0 (record outputs): Godot `--version`; `java -version`; `dir C:\Android\Sdk\platforms`; `git status`; `dir build`. Create helper scripts in `tools/` (PowerShell, e.g. `tools/run_tests.ps1`, `tools/build_debug.ps1`, `tools/capture.ps1`) that set `JAVA_HOME`, `ANDROID_HOME`/`ANDROID_SDK_ROOT`, and a project-local `ANDROID_USER_HOME` so the commands are repeatable.

## 2. PRODUCT GOAL AND DESIGN PRINCIPLES

LumiBlock is a calm, premium, offline 8×8 block puzzle for Android (portrait). Identity: **Calm Premium · Tactile Cubes · Subtle Luminosity · Timeless**. Not neon, not toy-like, not crowded. Each placement should feel weighty and satisfying; the screen must stay readable at 90% board occupancy; long sessions must not tire the eyes. Original identity — do not imitate any existing game's art, names, sounds or layouts.

## 3. AUDIT FINDINGS YOU MUST FIX (ground truth)

Reference format `F-xx [S|R] file:line`. **[S]** = statically confirmed in the code, **[R]** = reproduce/verify by test.

**P0 — correctness / data loss**
- **F-01 [S] main.gd:175,200,202 — crash.** After a piece is placed, `tray.remove_at()` shortens the tray; touching an empty slot sets `dragging` to an index ≥ `tray.size()`, and `_pointer_up` reads `tray[dragging]` → out-of-bounds. Also remaining pieces shift slots. *Fix:* tray is exactly 3 fixed slots, empty = `null`; the drag controller never captures an empty slot; remaining pieces never move.
- **F-02 [S] main.gd:173,204,211 — soft-lock.** `has_saved_session` is never cleared at game over; Home→RESUME opens a full board with no moves and game-over never re-triggers. *Fix:* session `state = "active"|"finished"`; only `active` is resumable; game-over is also evaluated on restore.
- **F-03 [S] main.gd:202, board_model.gd:34-55 — wrong line count.** Uses `cleared.size() / 8` on a de-duplicated cell list: 1 row + 1 column = 15 cells → 1 line. *Fix:* `clear_completed()` returns `{rows, cols, cells}`; lines = `rows.size() + cols.size()` everywhere (score, stats, daily).
- **F-04 [S/R] main.gd:35,112 — unsafe load.** `stats`/`settings` taken from JSON without defaults/type checks (missing key → runtime error; JSON numbers are floats → `str(3.0)` prints `3.0`). *Fix:* schema validation, defaults merge, int/float coercion, range clamps.
- **F-05 [S] save_service.gd — silent data loss.** Corrupt or newer-version file returns `{}` and is overwritten on next save; no backup. *Fix:* section 9.
- **F-23 [S/R] 64-bit RNG state through JSON.** `rng.state` is a 64-bit int written via JSON (float64) → precision loss → a resumed game's piece sequence differs. *Fix:* own 32-bit PRNG (section 8.4).

**P1 — product quality**
- **F-06 [S]** Drag geometry inconsistent: logical origin = finger cell, floating piece drawn 58 px above at 22 px scale, board preview at 39 px; anchor from piece top-left; tray piece still visible while dragging. *Fix:* section 7.
- **F-07 [S]** Multi-touch ignored (`index` never read); mouse/touch arbitration by a 300 ms heuristic. *Fix:* single event path + pointer ownership (section 7.2).
- **F-08 [S]** Settings are cosmetic: no audio, haptics, fonts or sound files exist; no `VIBRATE` permission in the export preset. *Fix:* sections 11–12.
- **F-09 [S]** Language selection is cosmetic: zero `tr()` calls; `project.godot` has no `[internationalization]` section so the `.translation` files are not even registered; CSV has only 6 keys and the `app_name` row has 15 values instead of 16. *Fix:* section 10.
- **F-10 [S] main.gd:77-80** Secondary buttons: label `#07101D` on `#2D3545` = **1.55:1** contrast. *Fix:* theme tokens (section 4) and an automated contrast test.
- **F-11 [S] main.gd:91,174** Dead `☰` control with no hit area; glyph may be missing from the font.
- **F-12 [S] main.gd:107-108,207-211** Daily Challenge is not a real mission (empty board, fixed 40 lines, no completion, progress reset on every start, shares `best` with classic). *Fix:* section 8.6.
- **F-13 [S]** Only 10 piece shapes, missing orientations (L-tromino 2/4, T 1/4, L-tetromino 1/8), no 1×4/1×5/2×3/3×3/V/S/Z; no weighting, no fairness guarantee. *Fix:* section 8.3.
- **F-14 [S/R] main.gd:45,65-75** `queue_redraw()` every frame, 64+ cubes × (new `StyleBoxFlat` + 2 polygons + line) per frame → allocation churn, battery drain. *Fix:* baked atlas + dirty redraw (section 5).
- **F-15 [S/R]** Fixed 390×844 layout, `aspect` default (keep) → letterboxing; no safe-area handling. *Fix:* section 6.
- **F-16 [R]** Android back key not handled (only `KEY_ESCAPE`); the default behaviour on Android is to quit. *Fix:* `quit_on_go_back=false` + router back handling (section 6.2).

**P2 — release / maintainability**
- **F-17** Package `com.example.lumiblock` (Play Console rejects `com.example.*`; verify at upload). **Do not change it without user approval** — see 15.2.
- **F-18** `export_filter="all_resources"` with empty exclude → `design/` (incl. a 1.7 MB ZIP, PNGs, HTML), `docs/`, `tests/` ship inside the APK.
- **F-19** Only a debug preset; no release preset/AAB/signing config/adaptive icon. `screen/handheld/orientation` in the preset is likely not a real key; orientation comes from `project.godot`.
- **F-20 [S]** `tests/test_core.gd` prints "passed" unconditionally and exits 0 (asserts don't set the exit code); coverage is 44 lines of model checks only; `tests/README.md` contradicts `TEST_REPORT.md`.
- **F-21** No fonts, audio, icon set or textures exist; icon is a placeholder.
- **F-22** No save on `NOTIFICATION_APPLICATION_PAUSED/FOCUS_OUT/WM_CLOSE_REQUEST`.
- **F-24 [R]** `INTERNET` permission may be on by default in the export; the game is offline.

**Stitch reference:** `design/extracted/...` is *inspiration only*. Its prose colours differ from its own implementation and from the code; it contains fake features (XP, gems, "Top 5% Global", cloud save, second chance, chests, rotate/reroll). Do not copy any of that. Do not modify or delete `design/`.

## 4. DESIGN SYSTEM — "CALM MIDNIGHT" (authoritative tokens)

Create `ui/theme/tokens.gd` (`class_name Tokens`) holding **only** these constants; every colour/size in UI code must come from it.

### 4.1 Colours

| Token | Hex | Use |
|---|---|---|
| `BG_0` | `#0C121D` | app canvas |
| `BG_1` | `#121A28` | secondary background |
| `SURFACE` | `#182235` | cards |
| `SURFACE_HI` | `#222E46` | secondary button fill, raised surfaces |
| `BOARD_WELL` | `#0F1624` | board well |
| `CELL_EMPTY` | `#1A2438` | empty socket |
| `PRIMARY` | `#62D6C4` | primary action |
| `PRIMARY_PRESSED` | `#4DBFAE` | primary pressed |
| `ON_PRIMARY` | `#04201B` | text/icon on primary |
| `ACCENT` | `#8E9CFF` | daily/links/focus ring |
| `TEXT_TITLE` | `#F3F6FD` | titles, scores |
| `TEXT_BODY` | `#C5CEE3` | body |
| `TEXT_MUTED` | `#8E9BB8` | passive |
| `SUCCESS` | `#6BD8A0` | success |
| `WARNING` | `#F0B866` | caution |
| `ERROR` | `#F27A8F` | error/invalid |
| `ON_SECONDARY` | `#E8EEFB` | text on `SURFACE_HI` |
| `HAIRLINE` | `#FFFFFF` @ 7% (top edge 12%) | 1 dp borders |
| `SHADOW` | `#02050A` | all shadows |
| `SCRIM` | `#02050A` @ 70% | modal backdrop |

Measured contrast (WCAG): title/surface 14.72, body/surface 10.09, muted/surface 5.71, on-primary/primary 9.72, on-secondary/surface-hi 11.67, accent/surface 6.33, success/surface 9.06, error/surface 6.03. **Add a unit test** `tests/unit/test_contrast.gd` that recomputes these (relative luminance formula) and fails if any text pair < 4.5:1 or any non-text UI pair (cube vs socket) < 3:1.

### 4.2 Cube families (5; index 0–4)

| idx | Name | `base` | `light` | `dark` | `edge` | `glow` | Mark (colour-blind aid) |
|---|---|---|---|---|---|---|---|
| 0 | Azure | `#61AFFF` | `#8EC7FF` | `#1588D8` | `#006AB6` | `#5FBAFF` | dot |
| 1 | Seafoam | `#5BCEBB` | `#88E5D4` | `#19A593` | `#008574` | `#58DBC6` | diamond |
| 2 | Orchid | `#9D7CAF` | `#B295C2` | `#775689` | `#583A6B` | `#AA85BE` | triangle |
| 3 | Coral | `#D06F6B` | `#E18C87` | `#A74746` | `#84282B` | `#E27672` | square |
| 4 | Saffron | `#C5A04E` | `#DCB973` | `#9B7923` | `#795C00` | `#D3AA4E` | plus |

Legacy saves store colours 0–3; they map 1:1 to Azure…Coral (index meaning changed, which is acceptable). Add a test: pairwise ΔE76 between `base` colours ≥ 20 under normal vision, deuteranopia and protanopia (Machado 2009 matrices); documented values at design time: ≥ 35.9 / ≥ 24.2 / ≥ 24.1.

### 4.3 Spacing, radii, elevation, motion

- Spacing scale: 4, 8, 12, 16, 24, 32. Screen side margin 16. Card padding 16. Section gap 24.
- Radii: button 16, card 20, modal 24, pill 999, cube = 22% of cell.
- Elevation (all `SHADOW` colour): card y+2 blur 12 α35%; modal y+8 blur 32 α50%; dragged piece y+10 blur 20 α45%. Do **not** use backdrop blur.
- Touch targets ≥ 48×48 dp, gaps ≥ 8 dp.
- Motion constants (`Tokens.MOTION_*`): `FAST=0.12s`, `BASE=0.22s`, `SLOW=0.40s`; default easing `Tween.TRANS_CUBIC` + `EASE_OUT`; no bounce/elastic anywhere except the documented "settle" in section 12 (E3).
- Typography: section 10.2.

## 5. CUBE RENDERER (signature element)

**Decision: pre-baked texture atlas, drawn with batched `draw_texture_rect_region` from custom `Control._draw()`; shaders only for one-off effects.** Reasons: GL Compatibility renderer, 64+ simultaneous cubes, predictable cost, screenshot-diffable, no per-device shader differences.

### 5.1 Bake tool
`tools/bake_cubes.gd` (`extends SceneTree`, run `--headless --script res://tools/bake_cubes.gd`; pure `Image` CPU work) writes `assets/cubes/cube_atlas.png` (RGBA8, lossless) and `assets/cubes/cube_atlas.json` (cell rects). Atlas: **cell size 128×128 px**, 4 columns × 6 rows (512×768):
- Rows 0–4 = families (Azure…Saffron). Col 0 = body. Col 1 = body + colour-blind mark. Col 2 = body, lifted variant (+4% light, no mark). Col 3 = reserved/empty.
- Row 5: col 0 = empty socket, col 1 = invalid-ghost hatch overlay (transparent bg, diagonal 45° lines, 2 px, white α35%, period 14 px), col 2 = white flash overlay (rounded rect α100%, tinted at draw time), col 3 = soft radial glow blob (white, gaussian, radius 64 px).
Draw cube with 4× supersampling (sample 4×4 per pixel) and these layers, in order, within a rounded rect of half-extent **59 px** (92% of 128 → 8% gap) and corner radius **28 px** (22%):
1. **Body gradient** along y: `light` at 0% → `base` at 45% → `dark` at 100% (smoothstep blend between stops; interpolate in OKLab or Lab, not sRGB).
2. **Top rim light:** 2 px band along the top edge, white α28%, fading to 0 over the last 12 px toward each corner.
3. **Bottom inner shadow:** darken (multiply `#000` α22%) over the bottom 6 px with a smooth falloff.
4. **Soft specular:** ellipse centre (32%, 26%) of the cube, radii (30%, 16%), white α10%, gaussian falloff.
5. **Edge stroke:** 1.5 px inside the silhouette, colour `edge` α35%.
No outer shadow in the atlas. Coverage anti-aliasing from the rounded-rect SDF: `sd = length(max(abs(p) - b + r, 0)) + min(max(q.x, q.y), 0) - r`, alpha = `clamp(0.5 - sd, 0, 1)`.
Socket (empty cell): same silhouette, fill `CELL_EMPTY`, a 3 px inner top shadow (black α35%) and 1 px bottom rim (white α6%) so it reads as a recessed well, **not** a raised cube.
Mark overlay: 28×28 px glyph centred, colour = family `dark` α55%.
Import settings for the PNG: no compression (lossless), mipmaps on, linear filter.

### 5.2 Runtime
- `BoardView` draws background well → 64 sockets → occupied cubes. Use `RenderingServer`-friendly batching: draw all with the same texture consecutively. Cell draw rect = cell pitch × 1.0 (the 8% gap lives inside the texture).
- `queue_redraw()` only when board data, ghost, highlight or theme changes (`dirty` flag), never from `_process`.
- Lifted/dragged piece: same atlas, scale to board pitch, plus one soft contact shadow (glow blob, black α45%, offset y+10, scale 1.15) **per piece**, not per cube.
- Valid ghost: family body at α55% + 2 px white α70% inner outline on the piece silhouette. Invalid ghost: body desaturated 60% toward `ERROR` + hatch overlay + no outline.
- Colour-blind marks setting toggles atlas column 1 vs 0.
- **Density rule:** at most **one** glow layer active at a time on the board; no per-cube glow when the board is > 50% full.
- **Performance gates** (measured on the phone, section 15.3): board redraw ≤ 1.5 ms at 64 filled cells; steady 60 fps while idle (no continuous redraw); < 1 MB atlas memory in VRAM compressed or ≤ 1.6 MB uncompressed.

### 5.3 Cube visual states (all required, all screenshot-tested)
resting, tray (scaled 40–62%), lifted/dragged, valid ghost, invalid ghost, selected (tray slot pressed: +4% light, ring `ACCENT` 2 dp), clearing (E5/E6), combo glow (E7), colour-blind marked.

## 6. LAYOUT, NAVIGATION, SAFE AREA

### 6.1 Project settings to apply (verify each key exists in 4.7.2)
```
[application] config/name="LumiBlock"; run/main_scene="res://app/app_root.tscn"; config/quit_on_go_back=false; config/version="0.2.0"
[display] window/size/viewport_width=390; viewport_height=844; window/stretch/mode="canvas_items"; window/stretch/aspect="expand"; window/handheld/orientation=1 (portrait)
[input_devices] pointing/emulate_touch_from_mouse=true; pointing/emulate_mouse_from_touch=false
[internationalization] locale/translations=<all 16 res://localization/strings.<loc>.translation>; locale/fallback="en"
[rendering] renderer/rendering_method="gl_compatibility" (and .mobile)
[audio] buses/default_bus_layout="res://assets/audio/default_bus_layout.tres"
[autoload] SaveService, SettingsService, LocalizationService, AudioService, HapticsService (in this order)
```
Remove the unused `ui_back` action and the unrelated `[animation]` compatibility line only if tests confirm nothing needs them. Evaluate `application/run/low_processor_mode=true`; adopt only if animations stay smooth on the phone.

### 6.2 Navigation controller (`app/screen_router.gd`)
`go(screen_id, params)`, `push_modal(scene, params)`, `pop_modal()`, `back()`. Screens: `home, game, daily, stats, settings, about, privacy, tutorial`; modals: `pause, confirm, language_picker, game_over` (game over may be a screen). Transition 0.22 s: new screen opacity 0→1 and y +12→0 dp, old screen fades out in 0.12 s; with reduce-motion: 0.08 s fade. Handle Android back via `NOTIFICATION_WM_GO_BACK_REQUEST` (and the equivalent action) with the matrix: Home → quit app; Game → open Pause; Pause → resume; Confirm dialog → cancel; Settings/Stats/Daily/About/Privacy → previous; Game Over → Home; language picker → close. Router must block navigation input during a transition (≤ 0.22 s) and never leave two screens active.

### 6.3 Layout system
Reference canvas 390×844 dp. Build **every** screen from Controls (containers, anchors, `size_flags`). No hard-coded absolute rectangles for UI. A pure `LayoutMetrics` (core/layout_metrics.gd) computes from `viewport_size` and `safe_area`: board side, cell pitch, tray slot rects, HUD heights. Formula:
```
margin = 16;   well_pad = 8
avail_w = viewport_w - 2*margin
fixed   = safe_top + hud(88) + status_row(28) + gap(12) + tray_h + gap(16) + safe_bottom + 16
board_side = min(avail_w, viewport_h - fixed)          # board is square
pitch = (board_side - 2*well_pad) / 8
tray_h = clamp(0.30 * board_side, 104, 132); slot_w = (avail_w - 2*8) / 3
```
Safe area: `DisplayServer.get_display_safe_area()` (screen px) converted to viewport units with `scale = viewport_size / DisplayServer.window_get_size()`; also consider cutouts. Log the raw values once at startup in debug builds. Recompute on `size_changed`. **Test matrix** (headless layout unit tests + screenshots): 360×640, 360×780, 390×844, 412×915, 430×932, 480×1000, 600×1024 (small tablet; board centred, max board side 520).
Status row height (28) is **always reserved** so the board never jumps when the combo chip appears.

## 6.4 Components (`ui/components/`)
Each is a reusable scene+script with exported properties, theme-driven styling, focus/pressed/disabled states, and a unit/UI test.
- `LBButton` (variants `primary`, `secondary`, `ghost`; sizes L=56, M=48; optional leading icon; pressed: scale 0.97 in 0.07 s + 8% darken; disabled α40%; focus ring `ACCENT` 2 dp; emits `pressed_action`; plays `ui_tap` + light haptic through the services).
- `LBIconButton` (48×48 hit area, 40 visual), `LBCard`, `LBToggle` (52×32, knob animates 0.12 s), `LBSlider` (min 48 dp touch height), `LBSegmented` (3 options), `LBStatCard`, `LBDialog` (confirm/info; Back = cancel), `LBToast` (bottom, 2.5 s, queue 1), `LBScoreLabel` (tabular figures, count-up animation, instant when reduce-motion), `LBComboChip`, `LBTopBar`.
Primary button fill: vertical gradient `PRIMARY` lightened 6% → `PRIMARY` → `PRIMARY_PRESSED`-ish bottom, 1 dp top highlight white α25%; text `ON_PRIMARY`. Secondary: `SURFACE_HI` fill, hairline, text `ON_SECONDARY`. Labels are **not** uppercased.

## 7. TOUCH INPUT AND DRAG-AND-DROP (critical)

### 7.1 Single event path
`emulate_touch_from_mouse=true`, `emulate_mouse_from_touch=false` (section 6.1). Handle only `InputEventScreenTouch` and `InputEventScreenDrag`. Delete the old `active_input_source` / 300 ms logic. Keep `Input.use_accumulated_input = true` (default) and read the latest pointer position once per frame in `_process` for rendering; use event positions directly for the drop decision.

### 7.2 `DragController` (`ui/game/drag_controller.gd`) state machine
```
IDLE ──touch down on filled slot (hit rect expanded by 8 dp)──► DRAGGING
DRAGGING ──touch up, resolve valid──► PLACING ──(≤160 ms visual)──► IDLE
DRAGGING ──touch up, resolve invalid / tap without move──► RETURNING (140 ms ease-out) ──► IDLE
DRAGGING ──cancel (below)──► RETURNING
```
- **Pointer ownership:** on touch-down store `owner_index = event.index`. Ignore every event whose `index` ≠ owner. A second finger never changes the drag, never drops it. If the owner touch ends, the drag ends; a different finger never takes over.
- **Cancel sources:** `NOTIFICATION_APPLICATION_FOCUS_OUT`, `NOTIFICATION_APPLICATION_PAUSED`, `NOTIFICATION_WM_WINDOW_FOCUS_OUT`, back key / pause button, viewport resize/rotation, modal opening, 2 s without any event while DRAGGING (lost touch-up). Cancel = RETURNING, game state unchanged.
- Input is ignored while a modal is open, during the first `0.16 s` after a PLACING/RETURNING starts only for **starting a new drag**; game state is already final when PLACING starts, so rapid sequences never desync.
- Empty slots (`null`) are never captured (F-01). Remaining pieces never move slots.
- All pointer positions are converted with `get_viewport().get_canvas_transform().affine_inverse()` once, in one function, into viewport coordinates. `BoardView` and `TrayView` expose `to_local_cell()` and slot rects from `LayoutMetrics`; nothing else does coordinate math.
- Signals: `drag_started(slot)`, `drag_updated(resolve_result)`, `drag_dropped(slot, origin)`, `drag_cancelled(slot)`.

### 7.3 `DropResolver` (pure, `core/drop_resolver.gd`) — the only place that maps finger → grid
Inputs: `pointer: Vector2` (viewport), `piece_cells: Array[Vector2i]`, `bbox_cells: Vector2i` (cols, rows), `pitch: float`, `board_origin: Vector2` (top-left of cell (0,0) in viewport), `board: BoardModel`, `assist: bool`, `prev_origin: Variant`.
```
w = bbox.x * pitch ; h = bbox.y * pitch
clearance = 0.9 * pitch
TL = Vector2(pointer.x - w/2, pointer.y - h - clearance)          # visual top-left of the lifted piece
TL = clamp TL so the piece stays fully inside the viewport (respect safe area)
g  = (TL - board_origin) / pitch                                   # continuous grid coordinate
o_raw = Vector2i(round(g.x), round(g.y))
if prev_origin != null and abs(g.x - prev.x) <= 0.62 and abs(g.y - prev.y) <= 0.62: o = prev   # hysteresis
else: o = o_raw
if assist and not board.can_place(cells, o):
    candidates = origins within Chebyshev distance 1 of o where can_place and distance(g, cand) <= 0.75
    o = nearest candidate (ties: smaller y, then smaller x), if any
valid = board.can_place(cells, o)
return {visual_top_left: TL, origin: o, valid: valid, over_board: any cell of piece inside board bounds}
```
Release uses **the same call with the release position**. The ghost drawn during the drag and the placement on release are therefore identical by construction. No random or constant offsets anywhere. The visual piece is drawn at `TL` at board scale (1.0 × pitch) and is **never** drawn in the tray slot while lifted (slot shows its empty "socket" outline).
Pickup animation: 90 ms ease-out-cubic from the slot's rest transform (tray scale 0.40–0.62) to scale 1.0 at `TL`, shadow fades in. Use `Control` offset transforms or a dedicated `DragLayer` (`CanvasLayer`-free `Control` above the board) so containers never reset it.
Invalid drop: piece animates back to its slot in 140 ms, light "denied" haptic + soft sfx; **never disappears, never mutates the board**.
Unit tests required for `DropResolver`: exact grid alignment, hysteresis (jitter ±0.3 cell produces no change), assist selection and tie-break, off-board, clamping at edges, 1×1 / 1×5 / 3×3 pieces, equality between preview call and release call for 1000 random pointer positions.

### 7.4 Edge cases to test (UI test with synthetic events)
Two simultaneous touches; touch-down on empty slot; touch-down during modal; app paused mid-drag; drag released outside the board; drag released exactly on a cell boundary; very fast flick (single `ScreenDrag` jump across the screen); touch cancelled by the system; dragging while the previous piece is still animating (allowed only after 160 ms); resize during drag.

## 8. GAME RULES, GENERATION, SCORING, DAILY

### 8.1 Board and placement (keep behaviour, improve API)
`BoardModel`: 8×8, `-1` = empty, `0–4` = colour. `can_place(shape, origin)`, `place(shape, origin, color)` must stay **atomic** (invalid placement leaves the board untouched — existing test). `clear_completed()` returns `{"rows": Array[int], "cols": Array[int], "cells": Array[Vector2i]}`; `place()` returns `{"valid": bool, "rows": [...], "cols": [...], "cleared": cells, "lines": rows+cols}`. Keep backward-compatible `cleared` key. `is_empty()` and `occupancy()` helpers. `has_any_move(shapes)` stays.

### 8.2 Session (`core/game_session.gd`, RefCounted)
Holds `board`, `tray[3]` (PieceModel|null), `score`, `streak`, `grace`, `lines`, `pieces`, `max_combo`, `elapsed_s`, `state`, `mode`, `rng`, `stream_index`. API: `place(slot, origin) -> Dictionary`, `to_dict()`, `static from_dict()`, `tick(delta)`. Signals: `piece_placed`, `lines_cleared(info)`, `score_changed(old,new)`, `combo_changed`, `tray_refilled`, `game_over(result)`, `mission_progress`. The tray refills only when **all three** slots are empty (then 3 new pieces). Game over = no tray piece has a legal placement, evaluated after every placement/refill **and on restore**.

### 8.3 Piece catalog and generator
Catalog entries have stable ids (`shape_id`) and normalized cells (37 orientations):
`mono`; `dom_h`,`dom_v`; `i3_h`,`i3_v`; `l3_0..3` (4 orientations of the 3-cell corner); `i4_h`,`i4_v`; `o4`; `t4_0..3`; `l4_0..3`; `j4_0..3`; `s4_h`,`s4_v`; `z4_h`,`z4_v`; `i5_h`,`i5_v`; `v5_0..3` (3×3 corner, 5 cells); `r23_h`,`r23_v` (2×3 rectangle, 6 cells); `sq3` (3×3, 9 cells). The existing 10 shapes must all exist in the new catalog with identical cell sets so v1 saves migrate. Add a test that every shape is connected, unique, normalized and that ids are unique.
`PieceGenerator.next_tray(board, rng, context)`:
- Size weights (base): 1 cell 4%, 2 cells 12%, 3 cells 24%, 4 cells 30%, 5 cells 20%, ≥6 cells 10% (`sq3` ≤ 1.5% inside the ≥6 bucket).
- Adaptation (classic): occupancy > 0.60 → weights of ≤3-cell shapes ×1.8; first 10 placements of a game → no shape with ≥ 6 cells; no tray with three identical `shape_id`; not all three colours equal.
- **Fairness guarantee:** at least one tray piece must have ≥ 1 legal placement on the current board (up to 12 re-rolls, then force a mono/domino). When occupancy ≥ 0.50, additionally search (budget 3 ms, `Time.get_ticks_usec`) for an order in which **all three** pieces can be placed sequentially; if the budget expires, accept the first-level guarantee.
- Daily uses `context = DAILY` → *board-independent* generation (everyone gets the same sequence; no fairness search).
- A headless tool `tools/sim_balance.gd` plays 10,000 seeded games with a greedy bot (maximise lines then minimise holes) and prints median/mean placements, score, p10/p90 game length and the % of games that ended with the first-level guarantee failing (must be 0). Record results in `docs/BALANCE_REPORT.md`; do not claim human-like difficulty from bot data.

### 8.4 PRNG
`SeededRng` (`core/seeded_rng.gd`): 32-bit mulberry32 (`state` is one non-negative int < 2³²). Methods `next_u32()`, `next_float()`, `range_int(a,b)`, `pick_weighted(weights)`. Deterministic across Godot versions. Test with a fixed-seed vector table. Never serialise Godot's `RandomNumberGenerator.state`.

### 8.5 Scoring (`ScoringEngine` + `core/scoring_config.gd`, constants in one place)
```
placement  = cells * 10
line_pts(n) = 50 * n * (n + 1)                # n = rows + cols cleared by this placement: 1:100 2:300 3:600 4:1000 5:1500
streak s: +1 for each placement that clears ≥ 1 line; a non-clearing placement keeps s for up to GRACE=2 consecutive non-clearing placements; the 3rd resets s to 0
mult(s)  = min(2.5, 1 + 0.25 * (s - 1))      # s ≥ 1
gain     = placement + round(line_pts(n) * mult(s)) + (PERFECT_BONUS=500 if the board is empty after the clear)
```
Keep the function `ScoringEngine.placement_score(cells, lines, combo)` callable for backwards compatibility (the old test calls it) but implement `ScoringEngine.gain(cells, n, streak, perfect) -> int` and migrate callers. Unit tests: table of expected values for n=0..5 × s=0..8, perfect bonus, grace behaviour (clear, miss, miss, clear keeps streak; miss ×3 resets). Constants are tunable but must live only in `scoring_config.gd`.

### 8.6 Daily challenge (`core/daily_challenge.gd`)
- Date: local calendar date `YYYY-MM-DD` from `Time.get_date_dict_from_system()` (not UTC). Seed `= fnv1a32("LUMIBLOCK-DAILY-" + date)`.
- Template = `seed % 3`: `0 LINES` (target N = 16 + (seed >> 3) % 9 → 16…24), `1 SCORE` (S = 2500 + 250 * ((seed >> 3) % 9) → 2500…4500), `2 COMBO` (K = 3 + (seed >> 3) % 3 → 3…5 streak).
- Start board: from `SeededRng(seed ^ 0x9E3779B9)` place 10–18 filled cells at random positions with random colours such that **no row/column is complete**; piece stream from `SeededRng(seed)`, context-free generator, `stream_index` stored in the session so resume is exact.
- Completion: the moment the target is reached the session ends as `result = "completed"` (score, seconds recorded for that date, streak updated). Running out of moves → `result = "failed"` (attempt counted; unlimited retries). Replaying a completed day is allowed "for fun": it never changes the completion record or the streak.
- Streak: consecutive completed dates (local), stored locally. Missing a day resets the *current* streak to 0 silently; no pressure UI, no warnings.
- Date rollover: while the app is open, on `NOTIFICATION_APPLICATION_RESUMED` and at local midnight (timer), refresh the Daily card; an **active** daily session from a previous date is finished as `result="expired"` with an info toast.
- Daily and classic sessions are independent: starting/continuing one never alters the other; `best_daily` is separate from `best_classic`.
- Tests: all 366 days of a leap year map to valid templates/targets (no exceptions); same date → identical start board and first 30 pieces; different dates → different; template distribution roughly uniform; completion/failed/expired transitions; streak logic across month/year boundaries.

## 9. PERSISTENCE — SAVE SCHEMA v2 AND MIGRATION

Implement `SaveService` (keep autoload name) + `core/save_schema.gd` + `core/save_migrations.gd`. Files in `user://`:
`lumiblock_save.json` (main), `lumiblock_save.bak.json` (last good), `lumiblock_save.corrupt.<unix>.json` (quarantine), `lumiblock_save.v1.bak.json` (one-time copy of the original v1 file before migration).

```
{ "schema": 2, "app_version": "0.2.0", "saved_at": <unix>, "checksum": "<sha256 hex>",
  "data": {
    "settings": { "language": "system|en|tr|es|pt-BR|fr|de|it|ja|ko|zh-CN|ar|hi|id|vi|ru|th",
                  "sfx": true, "music": true, "sfx_volume": 0.8, "music_volume": 0.6, "haptics": true,
                  "effects": "minimal|balanced|rich", "reduce_motion": false,
                  "placement_assist": true, "colorblind_marks": false, "text_scale": 1.0 },
    "records":  { "best_classic": 0, "best_daily": 0, "best_combo": 0 },
    "stats":    { "games_started": 0, "games_finished": 0, "games_abandoned": 0, "lines_cleared": 0,
                  "pieces_placed": 0, "perfect_clears": 0, "play_seconds": 0, "daily_completed": 0,
                  "daily_streak": 0, "daily_best_streak": 0 },
    "history":  [ { "ts": 0, "mode": "classic|daily", "score": 0, "lines": 0, "max_combo": 0,
                    "pieces": 0, "seconds": 0, "result": "over|completed|failed|expired|abandoned" } ],   // ≤ 30, newest first
    "daily":    { "completed": { "YYYY-MM-DD": { "score": 0, "seconds": 0, "ts": 0 } }, "last_streak_date": "" },
    "sessions": { "classic": <Session|null>, "daily": <Session|null> },
    "flags":    { "tutorial_done": false } } }

Session = { "id": "...", "state": "active|finished", "mode": "classic|daily", "date": "YYYY-MM-DD|''",
            "rng_state": u32, "stream_index": int, "board": [[int ×8] ×8],
            "tray": [ {"shape_id": "...", "color": 0-4} | null ×3 ],
            "score": int, "streak": int, "grace": int, "lines": int, "pieces": int, "max_combo": int,
            "elapsed_s": float, "started_at": unix }
```
Rules:
1. **Atomic write:** serialise → write `*.tmp` → verify by re-reading and parsing → if a main file exists copy it to `.bak.json` → move `.tmp` onto main. Check every return code; on failure keep the old file, emit `save_failed`, show a toast once, retry on next trigger. (On Windows, `DirAccess.rename` over an existing file may not overwrite — remove the target after the `.bak` copy succeeded, then rename; test the sequence on Windows with a unit test using a temp `user://` path.)
2. **Checksum:** sha256 (`HashingContext`) over the canonical JSON of `data`. Canonicalise by recursively converting integral floats (|x| < 2⁵³) to `int` and stringifying with sorted keys — apply the *same* canonicalisation when verifying (JSON parsing returns floats). Write `docs/SAVE_FORMAT.md` documenting this.
3. **Load order:** main → validate (JSON ok, `schema` known, checksum ok, schema validation) → else quarantine the bad file (rename) → try `.bak.json` → else defaults. Show one info toast ("Your save was repaired from backup" / "Your save could not be read; a new profile was created. The old file was kept.").
4. **Validation:** every field is coerced to its type and clamped (scores ≥ 0, volumes 0–1, `effects` enum, board cells −1..4, tray pieces must resolve via `PieceCatalog`; unknown shape → drop piece; if the tray ends up empty regenerate). Unknown extra keys are preserved when re-saving.
5. **Future versions:** `schema > 2` → never overwrite; run with in-memory defaults, set a flag that disables saving, show a warning toast.
6. **Migration v1 → v2** (`save_migrations.gd`): v1 payload is `{"version":1,"data":{"best":int,"stats":{"games","lines","best_combo","play_time"},"settings":{"sound","music","haptics","reduced_effects","language"},"active_mode":"classic|daily","sessions":{<mode>:{"active","mode","date","daily_lines","rng_state","screen","score","combo","board":{"cells":[[...]]},"tray":[{"shape":[[x,y]…],"color":int}]}}}}` (also a legacy top-level `"session"`). Map: `best`→`records.best_classic`; `stats.games`→`games_finished`; `lines`; `best_combo`→`records.best_combo`; `play_time`→`play_seconds`; `sound`→`sfx`; `reduced_effects`→(`effects="minimal"`, `reduce_motion=true`); language kept (the app-selectable value; `"en"` stays `"en"`); active sessions → v2 sessions with `shape` coordinate sets mapped to `shape_id` through the catalog (non-matching → null slot then refill), `combo`→`streak`, `daily_lines`→`lines`, `rng_state` **discarded** (re-seed from `started_at`/date and restore `stream_index = 0`; for daily it is acceptable that the remaining sequence restarts). Copy the original file to `lumiblock_save.v1.bak.json` first (never overwrite an existing `.v1.bak.json`). Fixtures: `tests/fixtures/save_v1_*.json` (healthy, partial, corrupted, with float-valued ints, with an active daily session, missing `sessions`, legacy `session`).
7. **Save triggers:** each placement; pause/resume/menu navigation; settings changes; game end; `NOTIFICATION_APPLICATION_PAUSED`, `APPLICATION_FOCUS_OUT`, `WM_CLOSE_REQUEST`, `WM_GO_BACK_REQUEST` on Home before quit. `play_seconds` accumulates in memory and flushes at most every 15 s plus on those triggers. Writes are debounced (max one write per 250 ms except on lifecycle triggers).
8. **Stats idempotency:** finishing a session processes stats exactly once (guard with `session.state`/`id`); `games_started` increments on a new session; leaving a new game via Restart/New Game counts `games_abandoned`.

## 10. FONTS, TYPOGRAPHY, LOCALISATION, RTL

### 10.1 Fonts (licence-safe only)
- **Primary UI/display font: Manrope** (SIL OFL 1.1), variable or static weights 500/600/700/800.
- **Script fallbacks (all SIL OFL):** Noto Sans Arabic, Noto Sans Devanagari, Noto Sans Thai, Noto Sans JP, Noto Sans KR, Noto Sans SC. Keep `allow_system_fallback = true` as a last resort.
- Put font files in `assets/fonts/` and the licence texts in `assets/fonts/LICENSES/` (one file per family: copy of OFL + copyright line). If the shell cannot download fonts (network off), do **not** hunt for other sources: create `assets/fonts/README.md` with exact download instructions (official GitHub/Google Fonts pages), implement the code so it works once the files exist, use Godot's built-in default font meanwhile and mark `BLOCKED(font files)` in the matrix. Never use a font whose licence you cannot confirm.
- **Subsetting:** CJK fonts are large. If Python + `fonttools` (`pyftsubset`) are available, create `tools/subset_fonts.py` that subsets the JP/KR/SC fonts to every character appearing in `localization/strings.csv` for that locale + digits + common punctuation + Latin basic, with `--layout-features='*'`. Otherwise ship full fonts only if the total APK increase stays < 12 MB, else mark BLOCKED. A test (`tests/unit/test_font_coverage.gd`) must verify every character of every translated string exists in the font chain for that locale (use `FontFile.has_char`).
- Verify with a script (fontTools or Godot) that Manrope contains Latin-Ext, Cyrillic, Greek and Vietnamese glyphs and an OpenType `tnum` feature; if `tnum` is missing, render score digits in fixed-width cells instead. Document the result in `docs/FONTS.md`.
- Font chain per locale is rebuilt in `LocalizationService` (e.g. `ja`: Manrope → Noto Sans JP → …; `ko`: … KR; `zh-CN`: … SC; `ar`: Manrope → Noto Sans Arabic; `hi`: … Devanagari; `th`: … Thai). Set `Label.language`/theme `language` so Han glyph variants follow the locale.

### 10.2 Typography scale (dp / line-height, weights)
`display_xl` 56/60 w800 · `display_l` 40/44 w800 (HUD score, stats numbers; tabular) · `headline` 28/34 w800 · `title` 20/26 w700 · `button` 16/20 w700 · `body` 16/24 w500 · `body_s` 14/20 w500 · `caption` 12/16 w600 · `overline` 12/16 w700. Letter spacing: display −0.5%, headline 0, button +1%, overline +8% **only for Latin/Cyrillic/Greek**; **0 for Arabic, Devanagari, Thai, CJK** (joining/shaping). No forced uppercase anywhere (Turkish İ/ı, German ß). Minimum text size 12 dp. `text_scale` setting (1.0 / 1.15) multiplies font sizes through the theme; layouts must not clip at 1.15 (screenshot test at 1.15 for Home, Settings, Game Over). Text alignment: start-aligned; numbers in stat rows end-aligned; centred only for titles/scores/buttons. Long labels wrap to 2 lines (never truncate without ellipsis); buttons grow in height before shrinking font.

### 10.3 Localisation
- **All** user-visible text moves to translation keys. Delete every string literal in UI code (tests grep for quoted literals passed to `Label.text`/`LBButton.text` in `ui/`). Keys are dotted lowercase (`home.play`). Plurals are avoided by phrasing ("Lines: {n}"); placeholders use `{name}` and are replaced with `tr(key).format({...})`.
- `localization/strings.csv` header `keys,en,tr,es,pt-BR,fr,de,it,ja,ko,zh-CN,ar,hi,id,vi,ru,th` (17 columns; **every row exactly 17 cells** — add a test). Let Godot import it, commit the generated `.translation` files, and register all 16 in `project.godot [internationalization] locale/translations` (F-09). Fallback `en`.
- Live switching: `LocalizationService.set_language(code)` → `TranslationServer.set_locale` → rebuild font chain → set RTL (10.4) → emit `locale_changed`; every screen refreshes dynamic strings in a `_on_locale_changed()` handler. No restart.
- Language picker lists each language **in its own name** (English, Türkçe, Español, Português (Brasil), Français, Deutsch, Italiano, 日本語, 한국어, 简体中文, العربية, हिन्दी, Bahasa Indonesia, Tiếng Việt, Русский, ไทย) plus "System default" (resolved from `OS.get_locale()`, falling back to `en`).
- `core/locale_format.gd`: `number(n, loc)` (digits stay 0-9 for all locales; grouping per locale: en/ja/ko/zh/ar/hi/th ","; tr/es/pt-BR/de/it/id/vi "."; fr U+202F; ru U+00A0), `duration(seconds, loc)` ("2 h 14 min" via keys `time.h`/`time.min`), `date(unix_or_ymd, loc)` (month names through keys `month.1..12` and a per-locale pattern key `date.pattern` such as `{d} {month} {y}`). Unit-test each locale.
- Translation quality: you produce the translations; mark them in `localization/REVIEW.md` as **machine-drafted, native review required** (do not claim they are reviewed). Keep wording short (buttons ≤ ~16 chars in English; allow +40% growth). Add a debug-only pseudo-locale (accented, +40% length, in `en_XA` style) to catch overflow, excluded from release builds.
- Tests: `tools/check_localization.gd` + `tests/unit/test_localization.gd` — every key in code exists in CSV; every key has a non-empty value in all 16 locales; placeholders identical across locales; no duplicate keys; row width = 17; all `.translation` files registered; screenshot of Home/Settings/Game Over in all 16 locales at 390×844 for human review.

### 10.4 RTL (Arabic)
For `ar`: set the window/root layout direction to RTL (verify the exact property: `get_window().layout_direction` or `Control.layout_direction`), mirror HUD/menus/lists/toggles/back arrows; **do not mirror** `BoardView`, `TrayView`, `DragLayer` (set LTR explicitly; game geometry must be identical in every locale). Text alignment follows direction. Verify shaping/joining with a screenshot and keep digits Western. Mixed LTR/RTL strings (e.g. "LumiBlock") must not reorder badly — test with the app name inside Arabic sentences.

### 10.5 English source strings (create these keys first; extend as needed)
```
app.name=LumiBlock            home.tagline=Place blocks. Clear lines. Find your flow.
home.play=Play                home.continue=Continue         home.new_game=New game
home.best=Personal best       home.best_none=Play your first game
home.daily=Daily challenge    home.stats=Statistics          home.settings=Settings
home.footer=Offline · No account
daily.title=Daily challenge   daily.rules_title=Today's rules
daily.mission.lines=Clear {n} lines    daily.mission.score=Reach {n} points    daily.mission.combo=Reach a {n}× combo
daily.rule1=Everyone gets the same start and piece order today.
daily.rule2=Reach the goal before you run out of moves.
daily.rule3=Retry as often as you like. Your streak is stored on this device.
daily.status.new=Not started   daily.status.progress=In progress   daily.status.done=Completed
daily.start=Start   daily.resume=Continue   daily.replay=Play again for fun
daily.streak=Streak: {n}   daily.best_streak=Best streak: {n}   daily.attempts=Attempts today: {n}
daily.progress=Progress: {a} / {b}   daily.expired=Yesterday's challenge ended. A new one is ready.
game.score=Score   game.best=Best   game.combo=Combo ×{n}   game.pause=Pause
pause.title=Paused   pause.saved=Your progress is saved   pause.resume=Resume   pause.restart=Restart
pause.settings=Settings   pause.menu=Main menu
confirm.restart.title=Restart game?   confirm.restart.body=This game will count as abandoned.
confirm.newgame.title=Start a new game?   confirm.newgame.body=Your current game will end and count as abandoned.
common.cancel=Cancel   common.confirm=Confirm   common.back=Back   common.close=Close   common.ok=OK
over.title=No moves left   over.new_best=New best   over.best=Best: {n}   over.lines=Lines   over.combo=Best combo
over.pieces=Pieces   over.time=Time   over.again=Play again   over.menu=Main menu
over.daily.done=Challenge complete   over.daily.failed=Not this time   over.daily.progress=You reached {a} of {b}   over.retry=Try again
stats.title=Statistics   stats.records=Records   stats.totals=Totals   stats.daily=Daily   stats.recent=Recent games
stats.best_classic=Best score   stats.best_daily=Best daily score   stats.best_combo=Best combo
stats.games=Games played   stats.lines=Lines cleared   stats.pieces=Pieces placed   stats.time=Play time
stats.perfect=Perfect clears   stats.daily_done=Days completed   stats.empty=No games yet. Your stats will appear here after your first game.
settings.title=Settings   settings.sound=Sound   settings.sfx=Sound effects   settings.music=Music   settings.volume=Volume
settings.feel=Feel   settings.haptics=Vibration   settings.effects=Effects   settings.effects.minimal=Minimal
settings.effects.balanced=Balanced   settings.effects.rich=Rich   settings.reduce_motion=Reduce motion
settings.gameplay=Gameplay   settings.assist=Placement assist   settings.marks=Shape marks on blocks   settings.text_size=Text size
settings.text_normal=Normal   settings.text_large=Large   settings.language=Language   settings.language_system=System default
settings.how_to=How to play   settings.about=About   settings.privacy=Privacy   settings.reset=Reset all data
about.title=About   about.version=Version {v} ({c})   about.licenses=Open-source licenses
privacy.title=Privacy   privacy.body=LumiBlock stores your progress and settings only on this device. It has no account, no ads, no analytics and does not use the network.
reset.title=Reset all data?   reset.body=This deletes your records, statistics and saved games on this device. This cannot be undone.   reset.done=All data was reset
tutorial.step1=Drag the shape onto the glowing spot   tutorial.step2=Full rows and columns clear   tutorial.step3=Three shapes at a time. No timer. The game ends when no shape fits.
tutorial.skip=Skip   tutorial.next=Next   tutorial.done=Let's play
toast.save_repaired=Your save was repaired from a backup   toast.save_unreadable=Your save could not be read. A new profile was created and the old file was kept.
toast.save_failed=Could not save your progress   toast.save_future=This save is from a newer version and was not changed
time.h=h   time.min=min   date.pattern={d} {month} {y}   month.1..month.12 (full names)
```
Remove `privacy.body`'s "no ads" claim if ads are ever added. The privacy text must stay true: verify the APK has no `INTERNET` permission (15.1).

## 11. AUDIO AND HAPTICS

### 11.1 Audio system
- `assets/audio/default_bus_layout.tres`: buses `Master`, `Music` (→Master), `SFX` (→Master). `AudioService` (autoload): 8-voice SFX pool (`AudioStreamPlayer`, bus SFX) + 1 music player (bus Music). `play(event: StringName, step: int = 0)`. Settings: `sfx` / `music` on-off (mute bus), volumes 0–1 mapped with `linear_to_db`. Music pauses on `NOTIFICATION_APPLICATION_PAUSED` and resumes on resume; no audio device → no errors. Changing the SFX toggle on plays a sample; the volume slider plays a sample on release.
- **All audio is original and generated by you** with `tools/synth_audio.gd` (`extends SceneTree`, run headless; builds `AudioStreamWAV` buffers — 16-bit mono — and writes `.wav` with `save_to_wav`; fixed seed → byte-identical output). No downloaded or third-party audio. Document the method in `docs/AUDIO.md` (this is also the licence statement: original, generated, no samples).
- Scale (all pitched sounds use it, so every combination is consonant): **D major pentatonic** D4 293.66, E4 329.63, F♯4 369.99, A4 440.00, B4 493.88, D5 587.33, E5 659.25, F♯5 739.99 Hz.
- Voices: **glass bell** = sines at f, 2.76f (×0.35), 5.40f (×0.15), attack 3 ms, exponential decay τ≈180 ms; **thud** = sine sweep 160→90 Hz over 70 ms with exponential decay + a 2 ms low-passed noise click at 12%; **tick** = 1–2 cycle burst at the stated frequency with a 5 ms decay. Peak-normalise each sound to −6 dBFS (clears/records) or −9 dBFS (UI/ticks); apply 2 ms fades to avoid clicks.
- Event map (file → description → length):
 `pickup` tick 880 Hz, 40 ms · `place` thud + tick 1500 Hz, 90 ms · `deny` two ticks 220 Hz 35 ms apart 50 ms · `clear_1..clear_5` ascending bell notes, n+1 notes (D4,E4,F♯4,A4,B4,D5 truncated), 60 ms apart · `combo_step` bell, pitch chosen by `step` (0..5) along the scale, 220 ms · `perfect` 5-note ascending motif + low pad swell, 900 ms · `record` 3-note ascending shimmer, 600 ms · `over` 3 descending soft bells (A4,F♯4,D4), 700 ms · `ui_tap` tick 1200 Hz, 25 ms · `toggle` tick 1000 Hz 30 ms · `daily_done` 5-note motif, 1000 ms.
- **Music:** `assets/audio/music/calm_loop.wav` — a **48 s seamless loop**, 32 kHz mono 16-bit, imported with IMA-ADPCM compression and loop on. Content: chord pads Dmaj9 → Bm9 → Gmaj7 → A6/9, 12 s each, each chord = three detuned (±6 cents) sine/triangle voices per note, 2.5 s attack, 3 s release, a very slow low-pass LFO, plus sparse seeded pentatonic plucks every 3–5 s with long decay. Peak −12 dBFS; default music volume 0.6 (SFX 0.8). Make the tail crossfade into the head so the loop has no click (verify by looking at the first/last 100 samples).
- **Honesty gate:** you cannot hear the result. Mark audio quality as `BLOCKED(human listening)` in the matrix until the user listens and approves; only structural checks (files exist, loop points, peaks, no NaN/clipping, no clicks via sample-delta check) may be PASS.

### 11.2 Haptics (`HapticsService` autoload)
- `pulse(kind)` where kind ∈ `tap, pickup, place, deny, clear(n), combo(k), perfect, record, over`. No-op when `settings.haptics` is false, when not on a mobile OS, or when called faster than every 40 ms; wrap in a guard so desktop/unsupported devices never error. Use `Input.vibrate_handheld(duration_ms, amplitude)` (verify the signature and that amplitude is accepted). Multi-pulse patterns run through a lightweight timer sequence (never `await` inside gameplay code).
- Patterns (duration ms @ amplitude): `tap` 8 @ 0.2 · `pickup` 12 @ 0.3 · `place` 18 @ 0.5 · `deny` 10 @ 0.25 ×2 (gap 40) · `clear(1)` 28 @ 0.6 · `clear(n≥2)` n pulses of 30/40/50 @ 0.6 (gap 50) · `combo(k)` min(k,3) pulses of 20 @ 0.5 ascending to 0.8 (gap 45) · `perfect` 40 @ 0.7 · `record` 2×25 @ 0.5 · `over` 60 @ 0.4.
- Android: enable **`permissions/vibrate`** in the export preset (the engine docs state it is required). Devices without amplitude control play full strength; devices without a vibrator ignore the call. Android's global "touch feedback" setting cannot be read from Godot — document this in `docs/HAPTICS.md` and give the in-app toggle.
- Turning haptics on in Settings fires one `tap` as a sample.

## 12. GAME FEEL AND EFFECTS (all effects cancellable, none blocks input)

Global rules: effects are owned by an `FxController` with a tween pool; leaving the screen, restarting or opening a modal `kill()`s them. Game state is final **before** any effect starts; input is never blocked by an effect except the 0.16 s new-drag lock in 7.2. No effect lasts > 600 ms (except ambient glow, record chip, Perfect chip). No screen shake anywhere. Effects level (`minimal|balanced|rich`) scales particles: 0 / 4 / 10 sparks per cleared line (pooled `CPUParticles2D` or manually drawn pooled sparks, max 120 alive). **Reduce motion = true** overrides everything: no position/scale tweens, no stagger, no particles, no glow pulses; fades ≤ 120 ms; counters jump to the final value.

| ID | Effect | Trigger | Duration / easing | Visual behaviour | SFX | Haptic | Cancel / reduced-motion | Perf note |
|---|---|---|---|---|---|---|---|---|
| E1 | Pickup | touch-down on filled slot | 90 ms, cubic-out | piece scales from tray size to board pitch and rises to `TL`; contact shadow fades in; tray slot shows empty socket | `pickup` | `pickup` | released without move → returns (E4); RM: instant, no scale tween | 1 tween |
| E2 | Drag | every frame while dragging | none (1:1 follow, no smoothing) | piece at `TL`; ghost snaps to `origin`; valid/invalid tint cross-fades 80 ms | — | optional tick 8 ms @0.15 on target-cell change, only when effects = rich, ≥ 60 ms apart | cancel → E4; RM: same (no motion added) | ghost redraw only when `origin` changes |
| E3 | Placement settle | valid drop | 160 ms: scale 1.0→1.04 (cubic-out 70 ms) →1.0 (cubic-in 90 ms); white flash overlay α25% 90 ms | placed cubes settle; contact shadow fades | `place` | `place` | RM: 60 ms fade-in, no scale, no flash | ≤ 9 cubes animated |
| E4 | Return / deny | invalid drop or cancel | 140 ms cubic-out | piece flies back to its slot, shrinking to tray scale; ghost fades | `deny` (invalid only) | `deny` (invalid only) | RM: instant | 1 tween |
| E5 | Line clear (n=1) | placement clears 1 line | ≤ 450 ms total | cleared cubes get white flash α60% 80 ms, then scale 1→0.6 and fade over 220 ms, staggered 18 ms per cell along the line; `+N` popup rises 24 dp and fades in 500 ms; sparks per effects level | `clear_1` | `clear(1)` | RM: 120 ms fade, no stagger/sparks, popup fades in place | board input stays live |
| E6 | Multi-line (n≥2) | placement clears ≥ 2 lines | ≤ 520 ms | as E5, 40 ms stagger between lines; well ring glow α0→18%→0 over 400 ms; popup scale 1.0→1.15 when n≥3 | `clear_n` | `clear(n)` | RM: as E5 | one glow layer |
| E7 | Combo | streak s ≥ 2 after a clear | chip in 120 ms (scale 0.9→1) | `Combo ×s` chip in the status row; well ring glow α = clamp((s−1)/6,0,1)×30%; pitch step +1 per streak (max +5); on streak reset the ring/chip fade out 300 ms | `combo_step(s)` | `combo(s)` | RM: chip appears with fade only; ring static α | ring is the single glow |
| E8 | Score tick | score changes | 250 ms count-up cubic-out; gain ≥ 300: label scale 1→1.08→1 (120 ms) and colour `TEXT_TITLE`→`PRIMARY`→`TEXT_TITLE` | HUD number | — | — | RM: instant | `LBScoreLabel` only |
| E9 | New record (in-game) | score first exceeds previous best (best > 0), once per game | chip 1.5 s | "New best" chip in HUD | `record` | `record` | RM: chip with fade only | — |
| E10 | Perfect clear | board empty after a clear | ring pulse 600 ms; chip 1.2 s | "Perfect" chip + `+500` popup | `perfect` | `perfect` | RM: chip only | — |
| E11 | Game over | no legal move | 600 ms delay, then 300 ms dim (board α→60%, cubes modulate desaturate), card slides up 24 dp + fade 260 ms; score count-up 700 ms (tap skips) | game-over card over the board | `over` | `over` | RM: 80 ms fade, no slide, no count-up | — |
| E12 | Screen transition | router | 220 ms (see 6.2) | fade + 12 dp rise | — | — | RM: 80 ms fade | — |
| E13 | Button press | touch down/up on `LBButton` | 70 ms down, 90 ms up | scale 0.97 + 8% darken | `ui_tap` | `tap` | RM: colour change only | — |
| E14 | Daily complete | daily target reached | 500 ms ring-draw + 1 s card | check ring stroke draws; subtle ring glow; no confetti | `daily_done` | 3×20 @0.6 | RM: check appears instantly | — |
| E15 | Tutorial hand | tutorial step 1 | 1.2 s loop | ghost hand/arrow moves slot → target | — | — | RM: static arrow | stops on first touch |
| E16 | Home breathing glow | Home visible | 6 s loop, alpha 4–7% | soft radial behind the logo | — | — | RM / effects=minimal: static | paused when Home hidden |

Colour use in effects: sparks and rings use the cleared cube family's `glow` colour, never pure white except the 80–90 ms flash.

## 13. SCREENS AND ARCHITECTURE

### 13.1 Screen-by-screen implementation (Control scenes; all text via `tr`)

Common: root `Control` full-rect; background `BG_0` + one baked radial backdrop texture (`assets/bg/backdrop.png`, 1024², teal `#62D6C4` α5% and periwinkle `#8E9CFF` α4%); content inside a `SafeAreaContainer` that applies the safe-area insets from `LayoutMetrics`; scrollable only where noted (Settings, Stats, About). Every screen implements `enter(params)`, `exit()`, `_on_locale_changed()` and emits `request_back`.

**Home** (`ui/screens/home/home_screen.tscn`). Vertical: 24 top gap → brand block (L-shaped 4-cube mark drawn from the atlas, wordmark `LUMIBLOCK` Manrope 800 with +12% tracking, `home.tagline` in `body_s`, height ≈ 200; ≈ 140 when viewport height < 700) → best card (overline `home.best`, number in `display_l`; if best == 0 show `—` and `home.best_none`) → primary button: if an **active** classic session exists, `home.continue` (primary) + `home.new_game` (secondary, opens confirm) else `home.play` → Daily card (calendar icon, localized date, mission sentence, status chip/progress bar/check; whole card is a button) → bottom row two secondary buttons `home.stats`, `home.settings` → footer `home.footer`. Actions: Play → (tutorial if `flags.tutorial_done` is false, else) Game(classic, new); Continue → Game(classic, resume); New game → confirm → abandon current (stats `games_abandoned`) → Game(new); Daily card → Daily; Stats → Stats; Settings → Settings. Back → quit. Entrance: cards rise 12 dp with 40 ms stagger (≤ 400 ms; RM: fade only).

**Game** (`ui/screens/game/game_screen.tscn`). Nodes: `TopBar` (pause icon button left; centre `game.score` overline + `LBScoreLabel` display_l; right `game.best` + number), `StatusRow` (always 28 dp; left: daily mission progress bar `daily.progress` when mode=daily; right: `LBComboChip`; centre: record/perfect chips), `BoardView`, `TrayView` (3 slots), `DragLayer`, `FxLayer`, `ModalHost` hooks. No bottom HOME/PAUSE buttons. Pause icon → Pause modal (stops timers, saves). `GameSession` signals drive HUD/FX; the view never changes game state directly. Tray empty slot shows a faint socket outline. Background app → auto-pause + save.

**Pause** (modal card 320 dp, scrim). Title `pause.title`; subtitle `pause.saved` **only if the last save succeeded**; buttons: `pause.resume` (primary; = back), `pause.restart` (secondary → confirm `confirm.restart.*`; on confirm: finish current as `abandoned`, start a new session of the same mode — for daily, a fresh attempt), `pause.settings` (opens Settings over the game; Back returns to Pause), `pause.menu` (saves, → Home; no confirm). Elapsed time freezes while open.

**Game Over** (modal/screen over the dimmed board). Classic: `over.title`, `LBScoreLabel` final score (700 ms count-up, tap skips), `over.new_best` badge only if a record was beaten (and best > 0), `over.best`, 2×2 `LBStatCard` (`over.lines`, `over.combo`, `over.pieces`, `over.time`), buttons `over.again` (primary → new classic session) and `over.menu`. Daily: `over.daily.done` or `over.daily.failed` + `over.daily.progress`, buttons `over.retry`/`daily.replay` (primary) and `over.menu`. Stats are committed exactly once when the session turns `finished`, before the UI appears (reopening the app on this screen must not double count). Back → Home. No share/rank/rewards.

**Daily** (`ui/screens/daily/daily_screen.tscn`). Header with the localized date; mission card (icon, sentence from `daily.mission.*` with the day's number, progress bar `daily.progress` when in progress, status chip `daily.status.*`, completed shows score and time); rules list (`daily.rule1..3`); streak row (`daily.streak`, `daily.best_streak`, local only) and attempts today; primary button: `daily.start` / `daily.resume` / `daily.replay` (completed day); Back. Updates on `NOTIFICATION_APPLICATION_RESUMED` and at local midnight; a stale active session is closed as `expired` and `daily.expired` toast is shown.

**Statistics** (`ui/screens/stats/stats_screen.tscn`, scroll). `stats.records` (3 `LBStatCard`: classic best, daily best, best combo), `stats.totals` (grid: games, lines, pieces, play time, perfect clears), `stats.daily` (days completed, current/best streak), `stats.recent` (up to 10 rows: localized date, mode icon, score, lines). Empty state `stats.empty` when `games_finished + games_abandoned == 0`. Numbers formatted with `LocaleFormat`. Values come from the real save; a UI test loads a fixture save and asserts every displayed number.

**Settings** (`ui/screens/settings/settings_screen.tscn`, scroll; sections as cards): Sound (`settings.sfx` toggle + volume slider, `settings.music` toggle + slider), Feel (`settings.haptics`, `settings.effects` segmented minimal/balanced/rich, `settings.reduce_motion`), Gameplay (`settings.assist`, `settings.marks`, `settings.text_size` segmented), Language (row opens the picker modal showing 16 native names + system default; selecting applies live and closes), How to play (re-runs the tutorial; no stats impact), About (version from `ProjectSettings` `application/config/version` + version code from the export preset constant in `Tokens`/`BuildInfo`, licences screen listing Godot's MIT notice (use `Engine.get_license_text()` / `Engine.get_copyright_info()` verified at runtime), Manrope/Noto OFL notices), Privacy (`privacy.body`; a policy-URL row appears only after the user supplies a hosted URL — until then it is hidden and tracked as `BLOCKED(privacy policy URL)`), Reset all data (confirm dialog, then wipes `data` to defaults but keeps the quarantine/backup files, toast `reset.done`). Every control writes through `SettingsService` immediately and has an observable effect covered by a test.

**Tutorial** (`ui/screens/tutorial/tutorial_overlay.tscn`). Uses the real `BoardView/TrayView/DragController` with a scripted `TutorialSession` (not saved, no stats): step 1 board has row 7 filled except 3 contiguous cells and the tray holds `i3_h`; hand animation E15; step 2 after the clear show `tutorial.step2`; step 3 shows `tutorial.step3` and `tutorial.done` → start a normal classic game and set `tutorial_done`. `tutorial.skip` always visible and also sets the flag.

### 13.2 Architecture and responsibilities
Create exactly this structure (do not move the five existing model/service files in `scripts/`):
```
app/app_root.tscn|gd, screen_router.gd
scripts/ board_model.gd piece_model.gd piece_catalog.gd scoring_engine.gd save_service.gd   (kept, extended)
core/ seeded_rng.gd piece_generator.gd drop_resolver.gd layout_metrics.gd game_session.gd daily_challenge.gd
      scoring_config.gd stats_tracker.gd save_schema.gd save_migrations.gd locale_format.gd color_math.gd
services/ settings_service.gd localization_service.gd audio_service.gd haptics_service.gd   (autoloads)
ui/theme/ tokens.gd theme_factory.gd      ui/components/ lb_*.gd|tscn      ui/screens/<name>/...
ui/game/ board_view.gd tray_view.gd piece_view.gd drag_controller.gd drag_layer.gd fx_layer.gd fx_controller.gd
assets/ fonts/ cubes/ icons/ audio/ bg/       localization/ strings.csv + *.translation + REVIEW.md
tools/ bake_cubes.gd synth_audio.gd render_icons.gd check_localization.gd sim_balance.gd capture_screens.gd
       subset_fonts.py run_tests.ps1 build_debug.ps1 capture.ps1
tests/ run_all.gd ui_runner.tscn unit/ integration/ ui/ fixtures/ screenshots/{golden,actual,diff}
docs/ CODEX_PROGRESS.md ACCEPTANCE_MATRIX.md API_NOTES.md SAVE_FORMAT.md FONTS.md AUDIO.md HAPTICS.md BALANCE_REPORT.md TEST_REPORT.md ANDROID_TEST_REPORT.md
_archive/v0.1.0_prototype/ (original main.gd, main.tscn)
```
- **Theme:** `ThemeFactory.build()` returns the `Theme` at runtime from `Tokens` (set on the root `Control`; no binary `.tres` to drift). Per-locale font chain applied by `LocalizationService`.
- **Layering rule:** `core/` and the model scripts know nothing about nodes/scenes/autoloads; they take their dependencies as arguments (this also makes headless tests independent of autoloads — `--script` mode may not instantiate autoloads, so test the pure code there and run UI/service tests through `tests/ui_runner.tscn` as the main scene).
- **Icons:** hand-author an original SVG set (2 dp stroke, round caps) in `assets/icons/`: play, pause, home, settings, stats, calendar, flame, check, close, back, volume, vibrate, globe, info, shield, reset. No third-party icon packs. Back arrow flips in RTL.
- **App icon:** redesign `icon.svg`: dark `#0C121D` rounded background, an L-shaped group of 4 cubes (azure, seafoam, orchid, coral) lit from the top-left, single faint glow; generate PNGs (512, 432 adaptive foreground/background, 192) with `tools/render_icons.gd` (`Image.load_svg_from_string`, verify it exists).

## 14. QUALITY ASSURANCE

### 14.1 Test runner (fixes F-20)
- `tests/run_all.gd` (`extends SceneTree`): discovers `tests/unit/test_*.gd` and `tests/integration/test_*.gd` (each exposes `func run(t) -> void`), provides `t.check(cond, msg)`, `t.check_eq(a, b, msg)`; **no bare `assert`**. Prints one line per test (`PASS|FAIL name (ms)`), a summary, writes `tests/last_run.txt`, and ends with `quit(1 if failures > 0 else 0)`. Command: `<godot> --headless --path . --script res://tests/run_all.gd`. Verify the runner itself by adding a deliberately failing test once and confirming exit code 1, then remove it.
- `tests/ui_runner.tscn` (main-scene override: `<godot> --headless --path . res://tests/ui_runner.tscn`) loads real autoloads, instantiates screens, injects synthetic `InputEvent`s and calls `get_tree().quit(code)`.
- Replace `tests/test_core.gd`'s unconditional "passed" with the new runner; keep its assertions by moving them into `unit/` tests. Fix `tests/README.md` and reconcile `docs/TEST_REPORT.md`, `docs/PROGRESS.md`, `docs/AUDIT_REPORT.md`, `docs/LOCALIZATION.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md` with reality at the end (statuses from the matrix only).
- Parser gate before every commit: `<godot> --headless --editor --path . --quit` must exit 0 with **no** `SCRIPT ERROR`/`Parse Error` lines (grep the output).

### 14.2 Required test files
`unit/`: board, board_clear, catalog, seeded_rng, generator, scoring, drop_resolver, daily, save_schema, locale_format, layout_metrics, contrast, atlas, font_coverage, localization. `integration/`: session_gameover, bot_game, daily_flow, save_roundtrip, save_migration, save_corruption, stats_idempotency. `ui/`: home, game_screen, pause, gameover, daily_screen, stats_screen, settings, language, tutorial, router, drag_multitouch, drag_cancel, reduce_motion, dead_controls. IDs and PASS criteria are in section 16.

### 14.3 Screenshot suite
`tools/capture_screens.gd` + `tools/capture.ps1`: headless uses a dummy renderer, so **capture in a windowed run** (`--rendering-driver opengl3 --resolution WxH`) and save `get_viewport().get_texture().get_image()` to `tests/screenshots/actual/<screen>_<WxH>_<locale>.png`. Sizes: 360×640, 390×844, 412×915, 480×1000 (plus 600×1024 for layout). Screens: Home (no session / with session), Game (empty board, mid-game, 56/64 dense, dragging with valid ghost, dragging with invalid ghost, clear animation mid-frame via deterministic frame stepping), Pause, Confirm, Game Over (classic new best / not best, daily done / failed), Daily (3 templates × new/progress/done), Stats (empty / filled), Settings (top/bottom), Language picker, Tutorial steps, About/Licences. Locales for Home/Settings/Game Over: all 16. Compare with `tests/screenshots/golden/` (≤ 0.5% differing pixels, per-channel tolerance 3); **golden images are created only after the user approves** (14.4), then regression-guarded.

### 14.4 Human visual review gate (mandatory, cannot be skipped)
After Phase 6 and again after Phase 8: build a review pack `docs/review/REVIEW_PACK_<n>/` with an `index.md` (what changed, screenshot list), all screenshots at 390×844 and 360×640, the dense-board shots, all cube states, a 16-locale contact sheet, and the contrast/colour-blind numbers. Then **stop and ask the user** to approve or list changes. Until the user answers, V-07 stays `BLOCKED`. Do not mark any visual-quality item PASS from automated results alone. When the user lists changes, fix them and regenerate the pack.

### 14.5 Performance and memory
Debug-only overlay (off in release): FPS, frame time, `Performance.OBJECT_NODE_COUNT`, `OBJECT_ORPHAN_NODE_COUNT`, `RENDER_TOTAL_DRAW_CALLS_IN_FRAME`. A `tools/stress_play.gd` mode plays 50 bot games through the real UI with effects at "rich" and records the numbers. Targets in section 16 (P-01…P-06). Never allocate `StyleBox`/`Resource` objects inside `_draw` or `_process`.

## 15. ANDROID BUILD, DEVICE PROTOCOL, RELEASE READINESS

### 15.1 Export presets and debug APK
- `export_presets.cfg` — **Android Debug** (runnable): keep `custom_template` empty, `gradle_build/use_gradle_build=false`; set `architectures/arm64-v8a=true` (others false unless the user asks), `permissions/vibrate=true`, `permissions/internet=false` (verify the real option names by reading the file Godot itself writes after you open/save the preset headless, or from the `--export-debug` warnings); `exclude_filter="design/*, docs/*, tests/*, tools/*, _archive/*, build/*, *.md, *.csv"` (keep `.translation`); icons from `render_icons.gd`; splash background `#0C121D` using the export-option splash settings introduced in 4.7. Remove the dubious `screen/handheld/orientation` key only if Godot reports it as unused. Keep `package/unique_name` as is until 15.2.
- Build: `<godot> --headless --path . --export-debug "Android Debug" build\lumiblock-debug.apk` (set `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, project-local `ANDROID_USER_HOME`). Then `aapt dump badging`, `aapt dump permissions`, `apksigner verify --verbose`, list entries (no excluded folders), record size + SHA-256 in `docs/ANDROID_TEST_REPORT.md` (matrix N-01…N-05). If a tool is missing say so — do not invent output.
- Keep `.gitignore` (`*.apk`, `*.aab`, `*.keystore`, `.android-user/`).

### 15.2 Package id, signing, release (user decisions)
- **Package id:** `com.example.lumiblock` must not be published (Play rejects `com.example.*`). A package id is **permanent** on Google Play, so do **not** change it yourself: in Phase 0 ask the user to choose one (lowercase reverse-DNS they control or at least own as a name, e.g. `com.<theirname>.lumiblock`) and apply it only after approval. Until then debug builds keep the current id.
- **Production keystore:** never create, read or commit it. Write `docs/KEYSTORE_GUIDE.md` with the exact `keytool` command the *user* runs, a note to store the file and passwords **outside** the repo and to back them up (loss = cannot update the app), and how to feed them to a release preset through environment variables / local untracked config. The release preset in the repo has empty credentials.
- **Release preset "Android Release"** with Gradle build (AAB): `gradle_build/use_gradle_build=true`, `gradle_build/export_format=1`(AAB, verify enum), install the Android build template inside the project, arm64-v8a. Gradle may need the network; if it cannot run, mark N-09 `BLOCKED(gradle/network or keystore)` — do not fake an AAB.
- **Target SDK:** as of 2026-11-14 Google Play requires new apps and updates to target **API 36** (the 1 Nov 2026 extension window has passed). The Godot 4.7.2 template reported `targetSdkVersion 36`; confirm with `aapt` and record. 16 KB page-size compatibility is required for modern targets — verify with `zipalign -c -P 16` (matrix N-05); if it cannot be verified say `UNVERIFIED`.
- **Developer verification context:** Android developer verification begins enforcement on certified devices in four countries from 2026-09-30 and expands in 2027; the user's Play identity-verification issue must be resolved before any upload. **Never upload or publish anything.**
- Store listing drafts (`docs/STORE_LISTING.md`): refresh for all claims actually true (offline, no account, no ads at launch, daily challenge, 16 languages) — remove anything not implemented. Data Safety draft (`docs/DATA_SAFETY.md`): no data collected or shared; data stays on device; valid only while N-02 shows no `INTERNET`.
- Versioning: `version/name` semver `0.2.0` for the first redesign build, `version/code` strictly increasing; document in `docs/RELEASE.md`.

### 15.3 Device protocol (physical phone, USB)
1. Build the APK (allowed without asking).
2. **Stop and ask the user** in plain language: "I'm ready to install the debug APK on your connected phone and launch it. Commands: `adb devices`, `adb install -r build\lumiblock-debug.apk`, `adb shell am start -n <package>/<launchable-activity>`, then read `adb logcat`. OK to proceed?" Take the launchable activity from `aapt dump badging` (do not assume `com.godot.game.GodotApp`).
3. Only after a yes: run the commands with `ANDROID_USER_HOME` inside the project; capture `logcat -d -s godot:*`, `dumpsys gfxinfo <pkg> framestats`, `dumpsys meminfo <pkg>`, `screencap` for evidence into `docs/device/`.
4. Ask the user to run the **manual device checklist** (write it to `docs/DEVICE_CHECKLIST.md` with tick boxes): first launch & tutorial; drag feel with thumb (occlusion, jump, latency); invalid drops; multi-finger touches; clear/combo effects readability; board at 56/64 filled; pause/resume; kill app mid-game and relaunch; back button on every screen; rotate-lock/gesture navigation bar overlap; language switch incl. Arabic and Japanese; settings toggles (sound, music, vibration actually felt); 20-minute session battery/thermal; low-battery/power-save mode; incoming call/notification interruption; screenshot for each screen. Record their answers; unticked = not passed.
5. Every result from the phone goes to the matrix with the evidence path; anything not run stays `BLOCKED`.

### 15.4 Release checklist (maintain in `docs/RELEASE.md`)
Package id (R-01) · icon/splash (R-02) · 512 px icon, 1024×500 feature graphic, 2–8 phone screenshots (R-03; the feature graphic needs human-made art unless the user accepts a simple generated one) · privacy policy URL hosted (R-04) · Data Safety (R-05) · content rating questionnaire answers drafted · target API 36 + 16 KB (N-02/N-05) · AAB with user keystore (N-09) · versioning (R-07) · licences (R-08) · Play identity verification (R-06) · internal → closed → production tracks (no uploading by you) · crash/performance results (P-03…P-05, N-10).

## 16. FINAL ACCEPTANCE MATRIX (create `docs/ACCEPTANCE_MATRIX.md` from this table in Phase 0 and update after each phase)

**Legend.** Status values: `NOT RUN` (initial), `PASS` (executed, evidence linked), `FAIL`, `BLOCKED` (cannot execute; reason stated). Auto = automated headless/CI-style; Man = needs a person; A+M = both. "Device" = physical Android phone, needs the user's permission (rule 0.5). Every row below must exist in `docs/ACCEPTANCE_MATRIX.md` with columns: **ID · Item · Method · PASS criterion · Auto/Man · Status · Evidence (command output file / screenshot path)**.

| ID | Item | Method (test name) | PASS criterion | Auto/Man | BLOCKED when |
|---|---|---|---|---|---|
| **CORE — rules & logic** |||||
| C-01 | Atomic placement | `unit/test_board.gd` invalid placement leaves board identical | board dict equal before/after; valid returns `valid=true` | Auto | — |
| C-02 | Row/column clear counting | `unit/test_board_clear.gd`: row, col, row+col cross, 2 rows+1 col, 8 rows | `lines == rows+cols` in every case; cross of 1 row+1 col = 2 lines, 15 cells | Auto | — |
| C-03 | Catalog integrity | `unit/test_catalog.gd` | 37 unique ids; all connected, normalized, no duplicates; the 10 v1 shapes present | Auto | — |
| C-04 | PRNG determinism | `unit/test_seeded_rng.gd` fixed-seed vectors | exact expected sequence; state < 2³²; JSON round-trip lossless | Auto | — |
| C-05 | Generator fairness | `unit/test_generator.gd` 5,000 trays on random boards | ≥ 1 placeable piece in 100% of classic trays; no triple identical id; colour rule holds | Auto | — |
| C-06 | Generator distribution | same | size buckets within ±3 pts of weights over 20,000 pieces (neutral board) | Auto | — |
| C-07 | Scoring table | `unit/test_scoring.gd` n=0..5 × s=0..8, perfect, grace | matches spec formulas exactly | Auto | — |
| C-08 | Session game-over | `integration/test_session_gameover.gd` | game over fires only when no tray piece fits; re-evaluated on restore | Auto | — |
| C-09 | Full bot game | `integration/test_bot_game.gd` 200 seeded games | no errors; score monotone; every game ends; stats consistent | Auto | — |
| C-10 | Balance report | `tools/sim_balance.gd` → `docs/BALANCE_REPORT.md` | report exists; first-level guarantee failures = 0 | Auto | — |
| C-11 | Daily determinism | `unit/test_daily.gd` | same date → same board + first 30 pieces; 366 leap-year days valid | Auto | — |
| C-12 | Daily completion | `integration/test_daily_flow.gd` | completed/failed/expired transitions; replay never alters completion/streak; streak across month/year | Auto | — |
| **SAVE — persistence** |||||
| S-01 | v2 round trip | `integration/test_save_roundtrip.gd` | save→load equals original incl. sessions, history, settings | Auto | — |
| S-02 | v1 migration | `integration/test_save_migration.gd` with all `save_v1_*.json` fixtures | fields mapped per spec; `.v1.bak.json` created once; active sessions resumable | Auto | — |
| S-03 | Corruption recovery | truncated / garbage / wrong-type / checksum-mismatch files | quarantine file created; `.bak` used if valid; defaults otherwise; no crash; toast event emitted | Auto | — |
| S-04 | Future schema | `schema: 3` file | not overwritten; saving disabled; warning event | Auto | — |
| S-05 | Float/int coercion | v1 fixture with `3.0` values | every numeric field int where int; Stats UI shows `3` not `3.0` | Auto | — |
| S-06 | Atomic write failure | inject failing rename | old file intact; `save_failed` emitted | Auto | — |
| S-07 | Stats idempotency | finish session, reload, reopen game-over | stats counted once | Auto | — |
| S-08 | Lifecycle save | send `APPLICATION_PAUSED` mid-game | save written (timestamp changes); resume restores same board/tray/score | A+M | Device portion BLOCKED until permission |
| **INP — input & drag** |||||
| I-01 | DropResolver math | `unit/test_drop_resolver.gd` | alignment, hysteresis, assist tie-break, clamp; preview == release for 1,000 random positions | Auto | — |
| I-02 | Single pointer owner | `ui/test_drag_multitouch.gd` synthetic 2 fingers | second finger ignored; owner end ends drag; no double drop | Auto | — |
| I-03 | Empty-slot safety | touch empty slot after placing 1 piece | no capture, no error (F-01 regression) | Auto | — |
| I-04 | Cancel paths | focus-out, pause, back, resize, 2 s timeout | piece returns, board/tray/score unchanged | Auto | — |
| I-05 | Invalid drop | drop outside / overlapping | piece returns; board unchanged; piece never lost | Auto | — |
| I-06 | Fast flick | single huge `ScreenDrag` jump | final resolve correct; no exception | Auto | — |
| I-07 | Visual = logical | screenshot at drop moment vs placed result | ghost cells == placed cells (programmatic compare of cell sets) | Auto | — |
| I-08 | Finger occlusion feel | hold piece with thumb on device; board cells under piece visible | piece bottom edge ≥ 0.9 cell above touch point; ghost fully visible | Man | Device not authorised |
| I-09 | Latency/feel | 10-minute play on device | no jump, no lag, no mis-drops reported by user | Man | Device not authorised |
| I-10 | Android back | back at each screen | per 6.2 matrix; app never exits except from Home | A+M | Device portion BLOCKED |
| **UI — screens** |||||
| U-01 | Home | `ui/test_home.gd` + screenshots | all buttons present/working; Continue only with active session; best card correct | A+M | — |
| U-02 | Game screen | `ui/test_game_screen.gd` | HUD updates from session signals; status row height constant; no dead controls | A+M | — |
| U-03 | Pause | `ui/test_pause.gd` | resume/restart(confirm)/settings/menu behave; timers freeze | Auto | — |
| U-04 | Game over (classic) | `ui/test_gameover.gd` | numbers match session; new-best badge logic; buttons work | Auto | — |
| U-05 | Game over (daily) | same | completed/failed variants correct | Auto | — |
| U-06 | Daily screen | `ui/test_daily_screen.gd` | status/progress/streak/attempts match save; midnight rollover handled | Auto | — |
| U-07 | Statistics | `ui/test_stats_screen.gd` with fixture | every displayed number equals fixture; empty state works | Auto | — |
| U-08 | Settings controls | `ui/test_settings.gd` | each control changes service state **and** observable behaviour (bus mute, haptics call counter, effects level, assist, marks, text scale) | Auto | — |
| U-09 | Language picker | `ui/test_language.gd` | all 16 selectable; live relabel without restart; persists | Auto | — |
| U-10 | Tutorial | `ui/test_tutorial.gd` | completes by scripted drag; skip sets flag; no stats impact | Auto | — |
| U-11 | Navigation graph | `ui/test_router.gd` | every button leads where spec says; no orphan screen; transitions block double-tap | Auto | — |
| U-12 | Dead-control scan | script walks scene trees | every `BaseButton`/`LB*` has a connected handler | Auto | — |
| U-13 | Responsive layout | `unit/test_layout_metrics.gd` + screenshots at 7 sizes | no overlap/overflow; board square; tray fits; targets ≥ 48 dp | A+M | — |
| U-14 | Safe area | layout test with injected cutouts + device log | content outside insets; values logged | A+M | Device portion BLOCKED |
| **VIS — visual quality** |||||
| V-01 | Contrast | `unit/test_contrast.gd` | text pairs ≥ 4.5:1; cube vs socket ≥ 3:1; documented values reproduced | Auto | — |
| V-02 | Colour-blind separation | same | ΔE76 ≥ 20 for all pairs under normal/deut/prot | Auto | — |
| V-03 | Cube atlas | bake tool + `unit/test_atlas.gd` | file exists, 512×768, alpha edges anti-aliased, regenerated bytes identical | Auto | — |
| V-04 | Cube states | `capture_screens.gd` renders every state | screenshots exist for 9 states × 5 families | Auto | — |
| V-05 | Dense board legibility | screenshot with 56/64 cells filled | human confirms cubes separable & sockets distinct | Man | Reviewer absent |
| V-06 | Screenshot regression | pixel diff vs golden (≤ 0.5% differing pixels) | all listed screens × 4 sizes | Auto | golden set not yet approved |
| V-07 | **Human design review** | user reviews screenshot pack (14.6) | written approval or change list | Man | until user responds → BLOCKED |
| V-08 | Typography scale | UI test reads theme font sizes | match 10.2; no size < 12 dp | Auto | — |
| V-09 | Text scale 1.15 | screenshots Home/Settings/Game Over | no clipping/overlap | A+M | — |
| V-10 | Reduced motion | `ui/test_reduce_motion.gd` | zero running position/scale tweens, zero particles with RM on | Auto | — |
| **LOC — localisation** |||||
| L-01 | CSV integrity | `unit/test_localization.gd` | 17 cells per row; keys unique; every key non-empty in 16 locales; placeholders equal | Auto | — |
| L-02 | Keys used = keys defined | code scan | no missing keys; no hard-coded UI literals in `ui/` | Auto | — |
| L-03 | Registration | project settings check | 16 `.translation` files registered; fallback `en` | Auto | — |
| L-04 | Live switch | UI test sets each locale | visible strings change; no restart | Auto | — |
| L-05 | Glyph coverage | `unit/test_font_coverage.gd` | every character in every translation exists in its locale font chain | Auto | font files missing → BLOCKED(font) |
| L-06 | RTL | screenshots `ar` for all screens | HUD mirrored; board/tray not mirrored; no broken joining | A+M | human review |
| L-07 | Formatters | `unit/test_locale_format.gd` | number/date/duration per locale table | Auto | — |
| L-08 | Pseudo-locale overflow | UI scan with +40% strings | no clipped/overlapping controls | Auto | — |
| L-09 | Translation quality | native review | reviewer sign-off | Man | BLOCKED until reviewed; stays "machine-drafted" |
| **AUD — audio & haptics** |||||
| A-01 | Assets exist | file check | all events in 11.1 present, 16-bit mono, peaks −6/−9 dBFS ±1, no NaN/clip | Auto | — |
| A-02 | Loop integrity | sample analysis | music head/tail delta < 0.02 at loop point | Auto | — |
| A-03 | Settings wiring | test double for bus/player | toggles mute bus; volume maps; samples play | Auto | — |
| A-04 | Haptics wiring | call-counter double | patterns as spec; throttled ≥ 40 ms; no-op when off/desktop; no errors | Auto | — |
| A-05 | Audio quality | listening | user approval | Man | BLOCKED(human listening) |
| A-06 | Real vibration | device | user feels pickup/place/clear; off toggle silences | Man | Device not authorised |
| **PERF — performance & memory** |||||
| P-01 | Idle redraw | profiler/frame counter | zero `queue_redraw` calls on `BoardView` while idle for 5 s | Auto | — |
| P-02 | Board redraw cost | microbenchmark 64 filled cells | ≤ 1.5 ms (desktop proxy); device value recorded | A+M | device value BLOCKED |
| P-03 | Frame rate on device | `dumpsys gfxinfo` + manual | ≥ 55 fps average, janky frames < 5% during 3-min play incl. clears | A+M | Device not authorised |
| P-04 | Memory | `dumpsys meminfo` start vs after 10 games | no growth trend > 15 MB; no orphan nodes (`Performance.OBJECT_ORPHAN_NODE_COUNT` = 0 after screen cycles) | A+M | device part BLOCKED |
| P-05 | Startup time | logcat time-to-first-frame | ≤ 2.0 s cold start on the user's phone (record value) | A+M | Device not authorised |
| P-06 | Allocation churn | script counts new `Resource` instances per frame during play | 0 per frame in steady state | Auto | — |
| **AND — Android** |||||
| N-01 | Debug APK builds | `tools/build_debug.ps1` | exit 0; file exists; size ≤ 32 MB | Auto | — |
| N-02 | Manifest facts | `aapt dump badging/permissions` | package as approved; `targetSdkVersion 36`; **VIBRATE present; INTERNET absent**; portrait; arm64-v8a | Auto | — |
| N-03 | Signature | `apksigner verify --verbose` | v2/v3 OK | Auto | — |
| N-04 | Export filter | list APK entries | no `design/`, `docs/`, `tests/`, `_archive/`, `tools/` | Auto | — |
| N-05 | 16 KB alignment | `zipalign -c -P 16 -v 4` (build-tools 35+) or ELF check | aligned | Auto | tool unavailable → report UNVERIFIED |
| N-06 | Install + launch | `adb install -r`, `am start` | app starts; first frame; no crash in `logcat` | Man | until user authorises |
| N-07 | Lifecycle | home/recents/rotate-lock/kill/restore | state restores; no crash | Man | Device not authorised |
| N-08 | Safe area / notch | visual on device | no content under cutout/gesture bar | Man | Device not authorised |
| N-09 | Release AAB | gradle/GABE release preset | `.aab` produced with user keystore | Auto | keystore/package/Play account → BLOCKED(user) |
| N-10 | Crash scan | `logcat -d` after 20-min play | no FATAL / Godot ERROR from our scripts | Man | Device not authorised |
| **REL — release readiness** |||||
| R-01 | Package ID | user approval | non-`com.example` id approved by user and applied | Man | user |
| R-02 | Icon & splash | `render_icons.gd` + visual | adaptive icon layers present; splash uses `BG_0` | A+M | — |
| R-03 | Store assets | screenshots, 512 icon, 1024×500 feature graphic | files present at correct sizes | A+M | feature graphic art human-made → BLOCKED until provided |
| R-04 | Privacy policy URL | user hosts policy | URL live and matches in-app text | Man | BLOCKED(user) |
| R-05 | Data Safety draft | `docs/DATA_SAFETY.md` | states: no data collected/shared, local storage only (valid only if N-02 shows no INTERNET) | A+M | — |
| R-06 | Play account | identity verification | resolved by user | Man | BLOCKED(user) — nothing is uploaded before this |
| R-07 | Versioning | `version/code` increments, `version/name` semver | documented in `docs/RELEASE.md` | Auto | — |
| R-08 | Licences | `assets/fonts/LICENSES`, in-app licences screen | all bundled third-party items listed | A+M | font files missing |

## 17. EXECUTION PHASES (work in this order; do not start a phase before the previous gate is green; do not stop between phases except at the user gates marked ⛔)

**Phase 0 — Preflight (≤ 1 session).** Verify environment (section 1); read every file under `scripts/`, `tests/`, `localization/`, `project.godot`, `export_presets.cfg`, `docs/`; archive originals to `_archive/v0.1.0_prototype/`; run the baseline parser + `test_core.gd` and record results; create `docs/CODEX_PROGRESS.md`, `docs/ACCEPTANCE_MATRIX.md` (section 16, all `NOT RUN`), `docs/API_NOTES.md`; reproduce F-01, F-02, F-03, F-05, F-23 with small scripts (or confirm by reasoning if not reproducible headless) and record `CONFIRMED/REFUTED`. ⛔ Ask the user **once**, in one message: the package id (15.2), whether a privacy-policy URL will exist, and whether font files can be supplied/downloaded. Do not wait for answers; continue with defaults and mark the dependent rows BLOCKED.
*Gate 0:* progress file + matrix + archive exist; baseline results recorded.

**Phase 1 — Core domain.** `BoardModel` API (8.1), `PieceCatalog` (37 shapes) + `PieceModel` ids, `SeededRng`, `PieceGenerator`, `ScoringEngine`/`scoring_config`, `GameSession`, `DailyChallenge`, `StatsTracker`, `LocaleFormat` (pure parts), `ColorMath`, `DropResolver`, `LayoutMetrics`; new test runner (14.1) with all `unit/` + core `integration/` tests; `tools/sim_balance.gd`.
*Gate 1:* `run_all.gd` exit 0; C-01…C-12, I-01, V-01/V-02 (math parts), U-13 (metrics) PASS with evidence; parser clean.

**Phase 2 — Persistence v2.** `save_schema`, `save_migrations`, `SaveService` rewrite (keep autoload name/path), fixtures, all S-01…S-07 tests.
*Gate 2:* S-01…S-07 PASS; the real v1 shape from the old `main.gd` loads through migration in a test.

**Phase 3 — Foundations.** Project settings (6.1), `Tokens`, `ThemeFactory`, fonts or font fallback plan (10.1), components (6.4), `ScreenRouter`, `AppRoot`, services (`Settings`, `Localization`, `Audio` stub, `Haptics` stub), `strings.csv` with all English keys and registration of the 16 `.translation` files, `check_localization.gd`.
*Gate 3:* app boots headless; router test passes; no hard-coded UI literals; L-01…L-03 PASS.

**Phase 4 — Cubes and board.** `bake_cubes.gd` + atlas, `BoardView`, `TrayView`, `PieceView`, ghost rendering, colour-blind marks, density rule, `capture_screens.gd` with the cube-state sheet.
*Gate 4:* V-03, V-04, P-01, P-02(desktop), P-06 PASS; cube-state sheet produced (look at it yourself and fix obvious defects: banding, jagged edges, muddy colours, marks illegible).

**Phase 5 — Input and Game screen.** `DragController`, `DragLayer`, Game screen wired to `GameSession`, HUD, status row, FX stubs.
*Gate 5:* I-02…I-07 PASS; the game is fully playable on desktop with mouse-emulated touch from first move to game over; no errors in the console during a 200-move bot-through-UI run.

**Phase 6 — Screens.** Home, Pause + confirm, Game Over, Daily, Statistics, Settings, language picker, About/Licences, Privacy, Tutorial; empty/error states; every screen's UI test; dead-control scan; responsive screenshots at all sizes.
*Gate 6:* U-01…U-14, V-08 PASS (automated parts). ⛔ **Human design review #1** (14.4): produce the review pack, ask the user, continue to Phase 7 in parallel only with work that does not depend on visual approval (audio, effects logic); apply requested changes before Phase 9.

**Phase 7 — Effects, audio, haptics.** `FxController` + E1…E16, `synth_audio.gd` + all assets, `AudioService`, `HapticsService`, settings wiring, reduce-motion/effect-level behaviour.
*Gate 7:* V-10, A-01…A-04 PASS; A-05/A-06 BLOCKED (human) recorded.

**Phase 8 — Localisation complete.** All 16 locales for every key (machine-drafted, flagged), fonts + per-locale chains, RTL, pseudo-locale, formatters, 16-locale contact sheet.
*Gate 8:* L-01…L-08 PASS (L-09 BLOCKED); ⛔ **Human design review #2** incl. Arabic/Japanese/Thai/Hindi screenshots.

**Phase 9 — Hardening.** Lifecycle handling (pause/resume/back/close saves), stress run, memory/orphan check, performance tuning, doc reconciliation (14.1), remove dead code, final parser gate, regenerate screenshots; create golden set **only after** user approval.
*Gate 9:* full `run_all.gd` + `ui_runner` green; P-01, P-02, P-04(desktop), P-06 PASS; docs consistent with the matrix.

**Phase 10 — Android.** Presets, icons/splash, debug APK + manifest/permission/size/signature checks, `DEVICE_CHECKLIST.md`, `RELEASE.md`, `KEYSTORE_GUIDE.md`, `STORE_LISTING.md`, `DATA_SAFETY.md`. ⛔ Ask permission before any device command (15.3). After approval: install, launch, collect evidence, ask the user to run the checklist.
*Gate 10:* N-01…N-05 PASS; N-06+ per user permission; everything else honestly BLOCKED.

## 18. REPORTING, FORBIDDEN BEHAVIOURS, DEFINITION OF DONE

**After each phase** append to `docs/CODEX_PROGRESS.md` and tell the user (short): what was built (file list), commands run with exit codes, matrix rows changed with statuses, open BLOCKED items, next 3 actions. Quote the real last lines of test output; never paraphrase a failure as success.

**Forbidden:** claiming a test passed that you did not run in this session; claiming device results without the user's authorisation and evidence; marking visual quality PASS without the user's approval; leaving UI controls that do nothing; adding any feature listed in rule 0.3; using unlicensed assets; touching files outside the project; changing the package id, creating a keystore or uploading anything without the user; silently deleting or overwriting user save data or the original project files; stopping after writing a plan; shrinking this specification without telling the user which part you dropped and why.

**Definition of Done** (all must hold, or the item is listed as BLOCKED with the reason):
1. Phases 0–10 gates are green except items that truly need the user/phone.
2. `run_all.gd` exits 0; `ui_runner` exits 0; the parser gate is clean.
3. Every button in every screen is exercised by a test and has a real effect; the dead-control scan is clean.
4. Drag-and-drop satisfies I-01…I-07 and the user's device checklist items for feel are either ticked or listed as open.
5. All 16 languages switch live; coverage tests pass; machine-translation status is disclosed.
6. v1 saves migrate; corrupted saves recover; no data-loss path remains.
7. Debug APK builds, manifest facts verified (no `INTERNET`, `VIBRATE` present, target API 36), size within budget.
8. Docs reconcile with reality; `docs/ACCEPTANCE_MATRIX.md` is complete with evidence links.
9. A final summary to the user lists: what is PASS, what is BLOCKED and why, what the user must do next (approve visuals, listen to audio, authorise device tests, choose package id, create keystore, host privacy policy, resolve Play identity verification).

**Begin now with Phase 0.** Your first actions are file reads and commands, not prose.