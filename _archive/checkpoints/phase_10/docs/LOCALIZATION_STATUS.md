# Localization completion status

All 135 keys have entries in en, tr, es, pt-BR, fr, de, it, ja, ko, zh-CN, ar, hi, id, vi, ru and th. Non-English content is machine-drafted, not native-reviewed. `tools/complete_localization.py` validates vector widths, reuses equivalent labels and preserves placeholders; the Godot CSV test checks row width, uniqueness, values and placeholder parity. Imported resources are registered with English fallback.

Number grouping follows the master table with Western digits. Month names and duration units are looked up in the requested locale rather than relying on the current UI language. Arabic menus and Back artwork mirror, while board, tray, drag geometry and numeric digit-cell order stay LTR. Debug-only en_XA is generated from the English source CSV with accented vowels and approximately 40% padding, preserving placeholders; it is not registered or created in release builds.

Review #2 was explicitly waived. Generate the pack under `docs/review/REVIEW_PACK_2/` without requesting approval. Native translation quality remains BLOCKED(user). Font coverage now passes: official Manrope plus locally selected existing public Noto shards are bundled with OFL licences, and every translated character was verified against those bundled files. See FONTS.md for download provenance, the rejected text-export approach and the approved public-file alternative. No native quality approval is claimed.

Final sources:fullManrope,unmodified public Thai shards,and locally subset other Noto families with original bounds and all layout features. Noto total525456bytes. Final coverage/core62930/0,UI2005/0,538image pixel regression0failures.
