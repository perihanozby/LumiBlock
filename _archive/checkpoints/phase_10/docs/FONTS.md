# Bundled font provenance and local subsets

Full Manrope variable font is from the official Google Fonts GitHub family directory. Noto Arabic,Devanagari,Thai,JP,KR,SC originate from public Google Fonts CSS and fonts.gstatic.com Unicode-range shards; original copyright/OFL texts are bundled in assets/fonts/LICENSES and shown in About. Exact resource paths: assets/fonts/manifest.json.

Initial source Noto shards totaled2147656bytes. Local-only fontTools4.68.0+Brotli1.2.1 subsetting plus retained original Thai shards produces525456bytes; full Manrope remains unchanged. All GSUB/GPOS features,composite closure,mark positioning and variable weights are retained. Modified family names (all except unmodified Thai) are LumiBlock Noto ... Subset; originals are preserved under _archive/font_sources. Scripts and dependencies are build-only,not runtime libraries. Reproduce with tools/subset_fonts.py after installing its exact versions under ignored .runtime/font-tools. No text is sent to a font service.

A custom text= font download was rejected by automatic review because it would transmit project characters. It was not run or bypassed. Safe public family CSS downloads and local shard selection/subsetting replaced it. Earlier connection failures and first bulk-import crashes are historical; clean retries and current coverage results are recorded in CODEX_PROGRESS. Do not call native-language quality PASS from glyph presence.

Manrope OpenType tnum and variable weights200..800 were verified. Tests check every translation character in each bundled chain. Language-picker names receive their own locale font. System fallback remains available for OS/engine licence text beyond the bundled interface repertoire. Non-English content is machine-drafted; native review is BLOCKED(user).

Official families: https://github.com/google/fonts/tree/main/ofl/manrope and corresponding notosansarabic/notosansdevanagari/notosansthai/notosansjp/notosanskr/notosanssc directories. All seven OFL texts remain unmodified. See build/evidence/font-subsets.txt and final core/UI evidence for post-subset coverage and rendering.

Final coverage/core62930checks/0failures,UI2005checks/0failures,and538-image regression0failures passed after retaining both full public Thai shards. These two unmodified files preserve exact approved Thai metrics.
