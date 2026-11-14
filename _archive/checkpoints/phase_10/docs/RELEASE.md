# Release readiness ? LumiBlock0.2.0(code2)

The redesign debug APK is built and manifest/signature/export/alignment verified. Exact artifact identity: bb1db99a7132d4b802f67b6024ab152cbea997bd3fd05f7c58a8813e2f979ef7;33064058bytes(31.5323MiB). Package com.perih.lumiblock was approved and applied only after initial manifest checks. This is a debug-signed test artifact,not a Play-ready release.

| Item | Status / action |
|---|---|
| R-01 Package | PASS,approved com.perih.lumiblock |
| R-02 Icon/splash | PASS,original512icon/adaptive432layers,verified BG_0 splash and actual phone splash capture |
| R-03 Store assets | BLOCKED(user),1024x500 feature art and2?8 approved phone screenshots;512icon ready |
| R-04 Privacy URL | BLOCKED(user),none hosted;URL row hidden |
| R-05 Data Safety | PASS draft,offline/no collection/sharing;owner must confirm Console answers |
| R-06 Play account | BLOCKED(user),identity/account access must be resolved by owner |
| R-07 Version | PASS,0.2.0/code2,increased from0.1.0/code1;increment code for every later distributed build |
| R-08 Licences | PASS,seven official font OFLs and Godot licence text exposed in About;original audio/icons/atlas |
| N-09 Signed release AAB | BLOCKED(user key),Gradle AAB preset/template ready,credentials blank |
| Human audio/native review | BLOCKED(user),machine drafts disclosed |
| Device manual checklist | BLOCKED(user interaction),no automatic tick inferred from launch |
| Atlas uncompressed memory | BLOCKED(spec conflict),required512x768RGBA8+mips approximately2MiB exceeds1.6MiB |

Read KEYSTORE_GUIDE.md for user-only signing setup. No keystore secrets belong in this repository/chat. Build presets retain empty custom-template overrides. Android build source/cache and runtime directories are ignored. No emulator,upload or publishing action was used.

Release flow for the owner:complete native/audio/device checks,host privacy policy,create/back up signing key,resolve Play verification,export and verify signed AAB,then use internal?closed?production tracks manually. Draft listing/content-rating and Data Safety are in STORE_LISTING.md and DATA_SAFETY.md. These drafts are not submitted forms.

Startup qualification remains BLOCKED:3.154s first-install display missed2s;later native-display values1.603s/1.242s are not gameplay-frame proof. Signed-release/manual cold-start profiling is still required.
