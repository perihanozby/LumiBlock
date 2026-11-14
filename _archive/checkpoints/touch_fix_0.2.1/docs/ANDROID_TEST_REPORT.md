# Android verification ? 2026-11-15

Debug APK: build/lumiblock-debug.apk. Godot4.7.2.stable.ed1daf0bf; Java17; SDK C:/Android/Sdk; build-tools35.0.0. All environment/user-home/runtime writes are project-local.

| Check | Executed result |
|---|---|
| Export/parser | PASS,exit0; tools/build_debug.ps1 |
| Package/version | com.perih.lumiblock,0.2.1/code3 |
| SDK/ABI/orientation | min24,target36,arm64-v8a only,portrait |
| Permissions | VIBRATE only; INTERNET absent |
| Size | 33068154bytes,31.5362MiB; budget interpreted as PowerShell32MB=33554432bytes |
| SHA256 | b0801228537b3186ec8a650082890ec882e86aa121c89ea36d9af91254038ecc |
| Signatures | apksigner exit0,v2/v3 verified; existing debug key only |
| Alignment | zipalign-c-P16-v4 exit0; both native libraries have16384-byte PT_LOAD alignment |
| Export contents | no design/docs/tests/tools/_archive/build/android/prototype main/raw CSV/Markdown; manifest and seven OFL notices present |
| Launcher | aapt xmltree MAIN/LAUNCHER alias com.godot.game.GodotAppLauncher; aapt35 badging omits aliases |

Raw outputs: build/evidence/android-final-{badging,permissions,manifest,signature,alignment,entries}.txt and android-final-facts.json. Initial manifest facts were first checked under com.example; only then was the user-approved package applied. This new package has separate Android app-private storage; old com.example data was not deleted or copied by device commands.

Original initial build34623127bytes exceeded the budget. Local official Noto subsetting reduced source2147656bytes to525456bytes (Thai shards retained unmodified) with all layout features and original bounding metrics preserved. Full Manrope remains. First bulk font import crashed; clean retry passed. Source originals/OFLs retained. Export emits an ICU compatibility warning; editor and installed official templates are both4.7.2. Generic Windows certificate/system-directory warnings remain visible. No script/parse error is accepted. An export-editor teardown warning is not runtime leak evidence; desktop stress reports zero orphans.

Gradle Android build template4.7.2 is installed in android/build and ignored from version control/export. Release preset uses Gradle and engine-probed AAB enum1,arm64,blank production credentials. N-09 BLOCKED(user): signed AAB requires a user-owned keystore; no production key was created/read and no AAB/upload is claimed. Gradle dependency/network execution remains unverified until signing setup.

Device results are summarized below after the final collection. Raw global logcat contains unrelated historical system crashes; only the app PID/window is used for app-crash conclusions. Short launch evidence does not establish20-minute play,three-minute FPS,ten-game memory trends,thumb feel or lifecycle correctness. All such manual items remain unchecked in DEVICE_CHECKLIST.md.

## Authorized physical-device evidence (0.2.0 baseline)

Final APK installed-r and launched with manifest-proven alias; all enumerated adb commands exited0. Current process7263,Adreno618 renderer. Screenshot launch-screen.png shows real Turkish Home. Safe-area log:physical1080x2400,raw(0,102,1080,2298),logical(0,36.805,390,829.195),viewport390x866. Home brand sizing uses the actual safe ScrollContainer height. No app-PID script/parse/fatal error was found in the short launch window; app-logcat.txt contains the scoped evidence. Raw global logcat has unrelated historical system faults and is not an app-crash claim.

Final passive gfxinfo:24launch frames,1janky(4.17%),median5ms,p95=8ms. meminfo baseline:PSS217603KiB,RSS316876KiB. These do not establish3-minute gameplay performance or10-game memory growth. Manual lifecycle,feel,audibility,vibration,all-screen safe areas and20-minute crash/thermal checklist remain BLOCKED(user). No input,lifecycle injection,uninstall,clear,pull,force-stop or kill command was used.

Startup remains BLOCKED(performance/manual profiling):first-install Activity Displayed3.154s exceeded2s. Rebuilt starts reported1.603s then1.242s to Activity Displayed,but these precede Godot's mainloop and cannot prove a gameplay first-frame bound. No first-gameplay-frame timing or repeated manual cold-start/release qualification is claimed. Production release profiling is blocked by the user-owned signing setup. Keep this limitation visible rather than passing it from a splash/native frame.

Screencap shell transport inserted CR before LF. Original transport bytes are retained as .transport.bin; only that transport escaping was reversed locally. The first screenshot's complete PNG chunk CRCs were verified. No pixel editing or unauthorized pull was used. First-install splash/Home/logs are retained separately. Android version/model were not queried because getprop is outside the approved command list; owner records them in DEVICE_CHECKLIST.

## Current touch repair - 0.2.1/code3

Source input emulation is enabled in both directions. Controls propagate scroll gestures through cards/buttons/toggles;labels ignore mouse;sliders own horizontal gestures with48dp minimum. Game input still accepts only ScreenTouch/ScreenDrag. Real desktop viewport regression,not direct Control handlers,passes2075UI checks including the added touch pipeline;core62930/0.

Current APK33068154bytes(31.536249MiB),SHAb0801228537b3186ec8a650082890ec882e86aa121c89ea36d9af91254038ecc. aapt badging/permissions/xmltree,signature v2/v3,16KB zipalign/ELF and export filters all exit0. tools/verify_android.py now validates version against both presets,project and BuildInfo instead of hardcoding the previous release.

Authorized install-r:exit0,Success. Verified launcher start:exit0. USB disconnected before the first screencap/gfxinfo/meminfo reads(each exit1);logcat eventually reconnected. Retried only authorized passive reads,all exit0;original failed attempt remains in status.initial_usb_read_attempt. Previous0.2.0 device files are preserved under device/previous-0.2.0. Current PID12992 has no app script/parse/fatal error in the short launch log;Home screenshot shows existing best5870. No data reset/uninstall,input injection or extra phone command was used. The reported scroll/slider gestures still require the user's physical re-test;installation is not that validation.
