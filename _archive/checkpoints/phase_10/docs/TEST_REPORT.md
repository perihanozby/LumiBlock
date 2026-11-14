# Current test report ? 2026-11-15

| Executed gate | Result | Evidence |
|---|---|---|
| Fresh requested parser/core/UI baseline | All exit0;62555 core checks,2001 UI checks,0 failures | build/evidence/resume-nov15-* |
| Phase9 parser | Exit0,no SCRIPT ERROR/Parse Error | build/evidence/phase9-final-parser.* |
| Phase9 final checksum/core | Exit0;62930 checks,0 failures,0 blocked suites | build/evidence/phase9-checksum-final-core.* |
| Phase9 actual OpenGL UI | Exit0;UI:2001 checks,0 failures | build/evidence/phase9-final-ui.* |
| Fractional-time independent probe | 10000 roundtrips,exit0 | build/evidence/phase9-save-precision-fixed.* |
| Real-UI rich-effects stress | 50 games+warmup,1840 drag moves,zero orphan nodes,stable52 nodes/105 resources,272124-byte growth | build/evidence/stress-ui.json;phase9-stress.* |
| Board renderer | 64-cell draw max206us,zero idle redraw requests in5seconds,no Resource growth | phase9-final-ui.stdout |
| Original audio deterministic regeneration | All21 WAV SHA256 match;waveform/loop tests PASS | build/evidence/audio-determinism.txt |
| Full bundled font coverage | All translated characters pass;16 locale chains | phase9-checksum-final-core.stdout |
| Review2 complete capture | Exit0;538 screens,seven layout sizes,16 locales at four sizes | phase9-complete-capture.*;review/REVIEW_PACK_2/index.md |

Regression comparison PASS:538 images,0failures,exit0; build/evidence/screenshot-regression.txt and phase9-final-diff.*. Independent repeat exit0. Tolerance remains3 per channel,at most0.5% differing pixels. Golden authority is explicit Review1 approval plus Review2 waiver; this is not native/audio/phone sign-off.

The first screenshot comparison failed(106/339). Capture settings/profile resets,time-varying effects and stale notices were fixed. Instrumented capture exposed a real Godot fractional-double JSON checksum drift. Exact canonical-byte verification now supplements semantic verification,with parser-data equality against duplicate-key ambiguity. Added timed-tick,disk,tamper,nested/escaped/duplicate-key tests; no saved values are rounded. Failures are retained as evidence,not relabelled successful runs.

Both runners catch engine/script errors and exit nonzero; intentional failing-check/runtime-error probes are retained in baseline evidence. Only observed Windows system-directory/certificate-store environment warnings are exempted. No project script failure is accepted. All tests use isolated save paths; external player profiles were not touched.

Desktop stress frame times include the greedy bot's synchronous search and one rendered frame per move; they cannot establish phone FPS or human-play timing. Phone lifecycle/feel/safe-area,three-minute performance and20-minute crash/thermal checks remain BLOCKED pending manual interaction. Audio quality and native translation review remain BLOCKED(user). Required lossless512x768 RGBA8+mipmaps is about2MiB and cannot also meet1.6MiB; BLOCKED(spec conflict).

## Final disposition

Final post-Thai-restoration core:62930checks,0failures,0blocked suites,exit0(done-core). UI:2005checks,0failures,exit0(done-ui),including replacement-root lifecycle board/tray/stream/score restore. Final screenshots:538captures,then538comparisons,0failures,exit0(done-capture/done-diff). Channel tolerance3 and0.5% limit unchanged;golden images unchanged. First post-subset5failures and next4Thai-only failures are retained in progress;final resolution retains original Thai shards and settles Settings scrolling. Parser/export exit0 before final build. Final64-cell redraw max247us,zero idle requests.

Final Android host verification:aapt badging/permissions/xmltree,apksigner v2/v3,zipalign16KB,ELF loads and actual ZIP exclusions all PASS,exit0. APK33064058bytes,31.5323MiB;exactSHA in ANDROID_TEST_REPORT. Authorized final install/launch/passive evidence exit0;no app-PID script/parse/fatal in short window. Phone manual performance/lifecycle/feel,audio/native review,signedAAB,user/privacy/Play/store-art and startup qualification remain BLOCKED;see matrix. No global system crash was called an app crash.
