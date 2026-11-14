# User-owned release signing

BLOCKED(user): no production key was created, read or used by Codex. The existing debug key is only for local testing. Do not publish the debug APK.

Run this yourself in a private terminal. Create the destination directory outside this repository first. The command prompts for passwords; never put them in command history, chat or Git:

```powershell
& "$env:JAVA_HOME/bin/keytool.exe" -genkeypair -v -keystore "$env:USERPROFILE/LumiBlockSigning/lumiblock-upload.jks" -alias lumiblock-upload -keyalg RSA -keysize 4096 -validity 10000
```

Keep encrypted backups of the key, alias and passwords outside the repository. Losing the signing material can prevent updates; retain the Play App Signing/upload-key recovery information too. Do not use the project-local debug key for production.

Godot supports GODOT_ANDROID_KEYSTORE_RELEASE_PATH, GODOT_ANDROID_KEYSTORE_RELEASE_USER and GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD as environment overrides. Set these privately for the current export process through your secret manager/terminal; do not add real credentials to export_presets.cfg or a checked-in script. The repository release preset intentionally has empty credentials. See the [official Godot4.7 environment-override table](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html#environment-variables).

After you have configured secrets and installed the required SDK/Gradle dependencies, run the engine with --headless --path . --export-release "Android Release" build/lumiblock-release.aab using tools/environment.ps1. The preset uses Gradle,AAB enum1 and arm64 only. Build template is project-local under android/build. Verify the signed artifact and upload certificate yourself. No upload/publish action is authorized or performed.
