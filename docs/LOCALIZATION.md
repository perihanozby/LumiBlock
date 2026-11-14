# Localization ? current implementation

135 keys have complete machine drafts in en, tr, es, pt-BR, fr, de, it, ja, ko, zh-CN, ar, hi, id, vi, ru and th. Sixteen imported translation resources are registered with English fallback. Every translated character passes bundled Manrope/Noto font-chain coverage; official OFL notices are in assets/fonts/LICENSES and exposed in About.

Live locale changes relabel screens. Arabic menus and Back artwork mirror; board/tray/drag geometry and score digits remain LTR. LocaleFormat handles date/month/duration and Western grouping. Debug en_XA expands source strings about 40%; it is not offered in release. CSV is a debug/editor input and is excluded from Android; .translation resources ship.

Machine drafts are not native review. L-09 remains BLOCKED(user); Arabic joining and translation quality require native readers. Review 2 was waived by the user. See review/REVIEW_PACK_2/index.md, FONTS.md and LOCALIZATION_STATUS.md.
