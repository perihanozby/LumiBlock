# LumiBlock Android Test Report

Date: 2026-11-14  
Engine: Godot 4.7.2 Stable  
Preset: `Android Debug`  
Package: `com.example.lumiblock`

## Build verification

- Godot executable: `C:\Users\perih\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`
- Java SDK: `C:\Program Files\Eclipse Adoptium\jdk-17.0.21.9-hotspot`
- Android SDK: `C:\Android\Sdk`
- Platform: API 35 present
- Build tools: 35.0.0 present
- Export templates: Godot 4.7.2 `android_debug.apk`, `android_release.apk`, `android_source.zip` present
- Debug keystore: existing Godot debug keystore found; not replaced
- APK: `build/lumiblock-debug.apk`
- APK size: 29,590,382 bytes
- SHA-256: `F5981B613F1848209182D6C33212138ACFB07FCB692E16F9CB3DCB6B37DB1647`
- `aapt dump badging`: package and version verified
- `apksigner verify --verbose`: v2 and v3 signatures verified

## Device status

Device: Redmi Note 9S (`curtana_global` / `curtana`), 1080x2400, density 440.

- Device enumeration: Pass; authorized ADB device `9c4341cb` detected.
- Existing package check: Pass; package was already installed before the test.
- `adb install -r`: Pass; streamed install returned `Success`, user data was not cleared.
- Cold launch via `monkey`: Pass; `GodotAppLauncher` resumed and remained foreground.
- Screenshot capture: Pass; [device-launch.png](device-launch.png) captured and visually inspected.
- Logcat crash scan: Pass; no `FATAL EXCEPTION`, `AndroidRuntime`, SIGSEGV or abort message observed after launch/relaunch.
- Background/foreground: Partially tested; force-stop/relaunch passed. The device image rejected the `move-task-to-back` command on this Android shell.
- Touch automation: Blocked; `adb shell input tap` was rejected with `INJECT_EVENTS` security permission. No automated touch result is claimed.

Visual review of the captured Home screen: portrait layout and contrast are readable, but the screen still has excessive unused lower space and lacks final iconography/cube illustration polish. This remains an implementation FAIL for the premium UI acceptance gate, despite the technical launch PASS.
