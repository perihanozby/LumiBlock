# Real touch repair - 0.2.1(code3)

The hypothesis was reproduced:emulate_mouse_from_touch=false prevented native Control drags. Test touch-repro exited1 with four failures:Settings0->0,Stats0->0,SFX0.8->0.8,Music0.6->0.6. Reproduction was recorded in progress/matrix before the fix.

Both emulation directions are now enabled. Cards/buttons/toggles PASS to ancestor ScrollContainer;passive labels IGNORE;sliders STOP and retain>=48dp touch height. Touch-index-only DragController guard remains intact. Real-input tests found and repaired Home daily-card press navigation:it now requires a completed tap,cancels on pan,and excludes child button taps.

| Check | Exit/result |
|---|---|
| Before-fix viewport reproduction | 1;5checks,4failures |
| Final parser | 0;no script/parse errors |
| run_all | 0;62930checks,0failures |
| full ui_runner | 0;2075checks,0failures |
| expanded touch/modal suite | 0;70checks,0failures |
| Debug build | 0;33068154bytes(31.536249MiB) |
| aapt/signature/filter/16KB checks | 0;com.perih.lumiblock,API36,arm64,VIBRATE,noINTERNET,v2/v3 |
| Install-r/verified launcher | 0/0;Success |
| Passive device reads | initial USB loss,then all retries0;failure retained |

APK:build/lumiblock-debug.apk;SHAb0801228537b3186ec8a650082890ec882e86aa121c89ea36d9af91254038ecc. Device collection used project-local ANDROID_USER_HOME and only the standing authorized commands. No phone gesture injection or data wipe. A real phone gesture re-test is still needed.

## Exact source/config/test files changed

- [app/build_info.gd](../app/build_info.gd)
- [export_presets.cfg](../export_presets.cfg)
- [project.godot](../project.godot)
- [scripts/save_service.gd](../scripts/save_service.gd)
- [tests/ui/test_home.gd](../tests/ui/test_home.gd)
- [tests/ui/test_touch_pipeline.gd](../tests/ui/test_touch_pipeline.gd)
- [tests/ui/test_touch_pipeline.gd.uid](../tests/ui/test_touch_pipeline.gd.uid)
- [tests/ui_runner.gd](../tests/ui_runner.gd)
- [tools/verify_android.py](../tools/verify_android.py)
- [ui/components/lb_button.gd](../ui/components/lb_button.gd)
- [ui/components/lb_card.gd](../ui/components/lb_card.gd)
- [ui/components/lb_slider.gd](../ui/components/lb_slider.gd)
- [ui/components/lb_toggle.gd](../ui/components/lb_toggle.gd)
- [ui/game/drag_controller.gd](../ui/game/drag_controller.gd)
- [ui/screens/menu_screen.gd](../ui/screens/menu_screen.gd)

## Documentation changed

- [docs/CODEX_PROGRESS.md](../docs/CODEX_PROGRESS.md)
- [docs/ACCEPTANCE_MATRIX.md](../docs/ACCEPTANCE_MATRIX.md)
- [docs/API_NOTES.md](../docs/API_NOTES.md)
- [docs/TEST_REPORT.md](../docs/TEST_REPORT.md)
- [docs/ANDROID_TEST_REPORT.md](../docs/ANDROID_TEST_REPORT.md)
- [docs/RELEASE.md](../docs/RELEASE.md)
- [docs/DEVICE_CHECKLIST.md](../docs/DEVICE_CHECKLIST.md)
- [docs/TOUCH_INPUT_FIX.md](../docs/TOUCH_INPUT_FIX.md)
- [tests/README.md](../tests/README.md)

Generated outputs:build/lumiblock-debug.apk and .idsig;build/evidence/touch-*,android-final-* and changed-file/audit manifests;docs/device/{status,install,launch,launch-screen,gfxinfo,meminfo,logcat,app-logcat,adb-devices} plus associated stderr/transport/retry files. Prior device evidence is preserved under docs/device/previous-0.2.0. Runtime/import caches are ignored. No fonts,atlas,audio,game rules or production signing material changed.

## Re-test on the phone

Confirm About0.2.1(code3). Scroll Settings from labels/toggle rows and Stats from cards/text. Drag both volume sliders,including slight diagonal motion;leave/reopen and confirm persistence. Repeat Pause->Settings. Pan language picker without selecting,then tap a language. Open/scroll About licences. Tap effects/text-size segments;Home daily card must tap once and not open during a swipe. Finally test ordinary/invalid/multifinger piece drags for no double drop or ghost jump. The detailed unchecked list is DEVICE_CHECKLIST.md.
