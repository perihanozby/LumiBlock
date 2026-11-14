# Calm Midnight design system

Authoritative executable tokens: ui/theme/tokens.gd. BG_0 #0C121D, surface #182235, primary #62D6C4, accent #8E9CFF, title #F3F6FD, body #C5CEE3. ThemeFactory supplies styles and bundled Manrope/Noto variable-font weights 500/600/700/800. Typography sizes: 56/40/28/20/16/14/12; minimum 12. Touch targets are at least 48 logical pixels; large buttons 56. Cards use radius 20, buttons 16 and modals 24.

Five original cube families use a deterministic 512x768 RGBA8 atlas with lossless import and mipmaps. All 45 family/state combinations are captured. Normal/protan/deutan separation and text/cube contrast are measured in build/evidence/palette-math.txt and tested. The atlas/mipmap spec conflicts with its 1.6 MiB uncompressed budget: base 1.5 MiB + mipmaps approximately 0.5 MiB = 2 MiB. BLOCKED(spec conflict); required dimensions/mipmaps retained.

Review 1 direction was approved. Review 2 is waived; updated bundled-font/16-locale captures remain available. Approval does not establish phone thumb feel or native translation quality. Reduced motion removes position/scale motion and particles; minimal/balanced/rich effects are service-driven and cancellable.
