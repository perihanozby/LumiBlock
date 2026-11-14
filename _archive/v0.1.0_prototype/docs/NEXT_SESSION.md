# Next Session

1. Confirm the current APK hash and rerun the core/localization tests.
2. Ask for explicit authorization before installing or launching the APK on the phone.
3. If authorized, make ADB usable with a writable user directory, enumerate the authorized device, install `build/lumiblock-debug.apk`, and capture `logcat`.
4. Test Classic drag/release, invalid placement, line clearing, pause/resume, background/foreground and save restoration.
5. Test Daily session separation, language cycling, settings persistence and portrait layout.
6. Record actual device results in `docs/ANDROID_TEST_REPORT.md` and update the acceptance matrix.
7. Do not declare production readiness until device QA, audio/haptics, responsive layout and localization review are evidenced.
