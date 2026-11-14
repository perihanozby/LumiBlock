# LumiBlock Test Report

Date: 2026-11-13  
Godot: 4.7.2.stable.official  
Workspace: `C:\Users\perih\Desktop\LumiBlock`

## Executed commands

```text
Godot_v4.7.2-stable_win64.exe --headless --editor --path C:\Users\perih\Desktop\LumiBlock --quit
Godot_v4.7.2-stable_win64.exe --headless --path C:\Users\perih\Desktop\LumiBlock --script res://tests/test_core.gd
Godot_v4.7.2-stable_win64.exe --headless --path C:\Users\perih\Desktop\LumiBlock --script res://tests/test_localization.gd
Godot_v4.7.2-stable_win64.exe --headless --path C:\Users\perih\Desktop\LumiBlock --quit-after 2
Godot_v4.7.2-stable_win64.exe --headless --path C:\Users\perih\Desktop\LumiBlock --export-debug "Android Debug" build\lumiblock-debug.apk
```

## Results

| Check | Result | Evidence |
|---|---|---|
| Godot editor import | Pass | Exit code 0; filesystem scan completed; no GDScript parser error after fixes. |
| Core GDScript suite | Pass | Output: `LumiBlock core tests passed`. Covers generated typed pieces, valid/invalid placement, no mutation on invalid placement, row/column clearing, normalization, duplicate/disconnected shape rejection and scoring. |
| Persistence and corruption decoder | Pass | Core suite covers PieceModel round-trip, valid payload round-trip, malformed JSON and future-version rejection. |
| Localization completeness | Pass | Output: `LumiBlock localization completeness test passed`; all 16 locale columns are present and non-empty. |
| Headless project startup | Pass | Exit code 0; only environment warnings about `user://logs` and root certificates. |
| Android debug export | Pass | `build/lumiblock-debug.apk` created; APK size 29,590,382 bytes. Export reached signing and verification. Current SHA-256: `F5981B613F1848209182D6C33212138ACFB07FCB692E16F9CB3DCB6B37DB1647`. |
| APK package metadata | Pass | `com.example.lumiblock`, version `0.1.0` / code `1`, label `LumiBlock`; `aapt dump badging` verified. The produced template reports `targetSdkVersion: 36` / `compileSdkVersion: 36`; Godot 4.7.2's Android template controls this value. |
| APK signature | Pass | `apksigner verify --verbose` passed; v2 and v3 signatures verified with one signer. |
| ADB device query | Blocked by sandbox | ADB could not create its default `.android` directory; no install or launch was attempted. |

## Not yet executed

- Interactive mouse/touch session on desktop.
- Physical Android installation and lifecycle test.
- Corrupt-save recovery and full save round-trip against a disposable test profile.
- Localization completeness test beyond the current five CSV keys.
- Performance measurement on the connected phone.

## Known non-project warnings

The managed execution environment prevents Godot from writing its global editor settings and `user://logs`, and prevents ADB from creating its default user directory. These warnings did not prevent the core suite or headless project startup from exiting successfully.
