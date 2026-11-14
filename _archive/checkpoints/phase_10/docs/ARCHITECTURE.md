# Architecture ? 0.2.0

AppRoot owns sessions, persistence, statistics and lifecycle; ScreenRouter owns screens and modals. Control-based screens live under ui/screens; reusable controls under ui/components. Tokens/ThemeFactory define the Calm Midnight theme. BoardView uses the original baked atlas and redraws only on invalidation. DragController owns one pointer and shares DropResolver between preview/release; DragLayer renders the lifted piece.

BoardModel, PieceCatalog, PieceModel, ScoringEngine and core GameSession/SeededRng/PieceGenerator/DailyChallenge are pure domain logic. Session tray slots remain fixed (null means empty). SaveService validates schema 2, checksums canonical data, migrates v1 with exact backup, quarantines corruption, restores backup, rejects future versions and reports atomic write failure. Production save path remains user://lumiblock_save.json; test and capture fixtures use isolated paths.

SettingsService drives AudioService, HapticsService, LocalizationService and live theme/layout changes. Audio has eight pooled voices and one looping music player; headless playback is disabled without a driver. FxController bounds particles and cancels on reduced motion/modal transitions. Localization loads 16 translation resources and bundled locale font chains.

Legacy prototype main scene/script are retained for preservation/compatibility and excluded from Android exports; the runnable main scene is app/app_root.tscn. Original copies remain in _archive/v0.1.0_prototype. Source checkpoints replace Git commits because .git is read-only.

See ACCEPTANCE_MATRIX.md for verified scope and open phone/human requirements.
