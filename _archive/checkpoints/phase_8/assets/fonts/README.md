# Approved fonts — bundled with licences

Update: an explicitly authorized download with network access succeeded for Manrope. Noto uses existing public Google Fonts Unicode-range WOFF2 shards selected locally; no project text or character list was uploaded. `manifest.json` lists the exact bundled files. All seven OFL licence files are in LICENSES/. Runtime glyph tests verify every character in all translations against its bundled locale chain. Current source font total is approximately 2.3 MB. The earlier failure below is historical, not the current coverage state.

The official Manrope download failed in this shell on 2026-11-14: unable to connect to remote server. Per the request's fallback rule, no alternate source was searched. Godot's built-in font is used, with system fallback permitted. Font coverage and the premium typography gate are BLOCKED(font).

Place the following official Google Fonts files here, using the listed names. Obtain each family's OFL.txt from the same directory and retain its copyright notice in LICENSES/<family>-OFL.txt.

- [Manrope](https://github.com/google/fonts/tree/main/ofl/manrope) → Manrope.ttf
- [Noto Sans Arabic](https://github.com/google/fonts/tree/main/ofl/notosansarabic) → NotoSansArabic.ttf
- [Noto Sans Devanagari](https://github.com/google/fonts/tree/main/ofl/notosansdevanagari) → NotoSansDevanagari.ttf
- [Noto Sans Thai](https://github.com/google/fonts/tree/main/ofl/notosansthai) → NotoSansThai.ttf
- [Noto Sans JP](https://github.com/google/fonts/tree/main/ofl/notosansjp) → NotoSansJP.ttf
- [Noto Sans KR](https://github.com/google/fonts/tree/main/ofl/notosanskr) → NotoSansKR.ttf
- [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) → NotoSansSC.ttf

Do not bundle a font without its OFL file. CJK files must be subset to translated characters before export if full files exceed the size budget. LocalizationService detects these paths automatically after Godot import.
