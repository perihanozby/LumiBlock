# LumiBlock Acceptance Matrix

| Area | Acceptance criterion | Status | Evidence / next action |
|---|---|---|---|
| Board | 8x8 initialization and bounds | Pass | `test_core.gd`; `BoardModel` |
| Placement | Collision/out-of-bounds rejection without mutation | Pass | `test_core.gd` |
| Clearing | Row/column clearing and typed clear results | Pass | `test_core.gd` |
| Shapes | Normalization, uniqueness and connectivity | Pass | `PieceCatalog` and core test |
| Tray | Three generated pieces and refill path | Pass | Core generation test; interactive refill pending |
| Game over | No-fit detection | Pass | `BoardModel.has_any_move`; interactive session pending |
| Scoring | Placement, line and combo formula | Pass | `ScoringEngine` core assertion |
| Touch | Screen drag events, preview and cancellation | FAIL | Code path exists, but `adb shell input tap` is blocked by device `INJECT_EVENTS`; manual finger test remains required |
| Pause | Overlay, resume and home save path | Implemented | Headless import; interactive validation pending |
| Persistence | Versioned JSON, safe decode, PieceModel round trip | Pass | Core test; real user-file recovery pending |
| Daily | Deterministic seed and mode-separated session data | Implemented | Code inspection; date rollover test pending |
| Localization | 16 locale columns and non-empty values | Pass | `test_localization.gd`; Godot reimport completed |
| Visuals | Shared beveled cube renderer and palette | Implemented | `main.gd`, `DESIGN_SYSTEM.md`; device visual review pending |
| Android | Debug APK export, metadata and v2/v3 signature | Pass | `ANDROID_TEST_REPORT.md` |
| Device | Install, launch, touch, lifecycle and logcat | PARTIAL | Install/launch/logcat passed; touch automation blocked and background command unsupported |
| Premium UI | Stitch-quality responsive composition and final visual polish | FAIL | Device screenshot is readable but still prototype-like with excessive unused space and missing final iconography |
| Release | Signed AAB, store assets and policy review | Open | Release phase after device QA |
