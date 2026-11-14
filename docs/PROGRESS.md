> Historical prototype report. This is not current-session acceptance evidence. See [CODEX_PROGRESS.md](CODEX_PROGRESS.md) and [ACCEPTANCE_MATRIX.md](ACCEPTANCE_MATRIX.md) for the current implementation and executed results.

# LumiBlock Progress

## Completed in this session

- Audited project files, scenes, scripts, localization resources, export preset and reference archive.
- Reproduced the typed-array contract failure from generated tray piece to `BoardModel.can_place`.
- Added `PieceModel` with typed `Array[Vector2i]` shape ownership.
- Repaired tray generation, `has_any_move`, save serialization and save payload validation.
- Added shape uniqueness/connectivity validation.
- Added deterministic core assertions for valid/invalid placement, no-mutation failure, line clearing, normalization, generated pieces and typed contracts.
- Ran Godot 4.7.2 headless import and core tests successfully.
- Verified Godot Android export templates, JDK 17, SDK API 35/build-tools 35.0.0 and the existing debug keystore.
- Enabled ETC2/ASTC VRAM import in `project.godot` and produced a signed debug APK at `build/lumiblock-debug.apk`.
- Verified APK package metadata with `aapt` and v2/v3 signature with `apksigner`.
- Added touch drag-motion handling, duplicate mouse/touch suppression, focus-loss drag cancellation, functional settings/language controls and a shared beveled cube renderer for board, tray and previews.
- Rebuilt the debug APK after these changes; current SHA-256 is `F5981B613F1848209182D6C33212138ACFB07FCB692E16F9CB3DCB6B37DB1647`.

## Current blockers

- ADB can be invoked but the sandbox prevents its default `.android` directory creation; device testing requires a writable Android user-home configuration and explicit install/launch authorization.
- Git checkpoint commit was attempted but `.git/index.lock` creation is denied by the environment.

## Next work

- Finish pause overlay, drag preview, valid/invalid placement feedback and responsive layouts.
- Complete save round-trip/corruption tests and independent daily session persistence.
- Migrate all UI literals to localization keys and generate completeness report.
- Request permission for device installation, then run the authorized ADB install/launch and lifecycle checks.

