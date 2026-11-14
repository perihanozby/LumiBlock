# Data Safety draft ? owner must confirm in Play Console

This build has no INTERNET permission. Gameplay, settings, statistics and daily records stay in Android app-private storage; there is no account, server, analytics SDK, advertising SDK, purchase flow or cloud synchronization. The app does not collect or share user data. VIBRATE supports optional haptic feedback. Audio and fonts are bundled for offline use.

Draft answers: data collected:no; data shared:no; account creation:none; account deletion:not applicable. Reset progress clears local gameplay data after confirmation; reset settings separately restores preferences. Uninstall removes app-private data according to Android behaviour. No network transmission/encryption claim is needed because no app network transport is implemented.

These answers apply only while the verified final manifest contains no INTERNET and no new SDK/service is added. See ANDROID_TEST_REPORT.md and build/evidence/android-final-permissions.txt. The owner must review the Console questionnaire and host a matching privacy policy before submission. R-04 is BLOCKED(user): no URL yet; the in-app URL row remains hidden.
