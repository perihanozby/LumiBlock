# Fonts — current result

Manrope variable TTF is bundled from the official Google Fonts GitHub repository. The six Noto families are bundled as existing public WOFF2 Unicode-range files from Google Fonts, selected locally against the locale text. All seven OFL texts, including their copyright notices, are saved next to the fonts. Source files total approximately 2.3 MB, within the 12 MB increase budget even before APK compression. No fontTools dependency was installed.

Automatic approval review rejected sending project characters in a Google Fonts text-subset request. The safe alternative fetches only public family CSS and existing font URLs; local character selection never leaves the project. This was approved and executed. The former fallback-only status below is historical.

`test_font_coverage.gd` executed and verified every translated character against Manrope plus its locale-specific Noto chain. Core result including coverage: 62555 checks, 0 failures, zero blocked suites. The first bulk import crashed with access violation; an immediate clean import retry exited 0, followed by successful runtime loading/glyph tests. OpenType table inspection confirms Manrope contains tnum; HUD score digits also retain fixed-width cells and LTR order. Variable weight instances are assigned at 500/600/700/800 through ThemeFactory.

Official API background: https://developers.google.com/fonts/docs/css2 . Download/reproduction helper: tools/download_fonts.ps1. Licence files are unmodified official OFL texts. Native typographic quality remains subject to native review, despite verified glyph coverage.

## Historical fallback record

BLOCKED(font): the authorized official Manrope download could not connect; the request requires built-in fallback rather than searching other sources. No downloaded or unlicensed font is bundled. See assets/fonts/README.md for exact official families, names and licence locations.

Manrope script coverage and tnum inspection are NOT RUN because its font file is absent. Scores will use fixed-width digit cells, so score alignment does not rely on tnum. Script-specific shaping and glyph coverage require font files plus human screenshot review; built-in/system fallback is not evidence of full coverage.
