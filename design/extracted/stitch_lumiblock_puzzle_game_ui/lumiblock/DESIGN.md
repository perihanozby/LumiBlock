---
name: LumiBlock
colors:
  surface: '#0b1322'
  surface-dim: '#0b1322'
  surface-bright: '#31394a'
  surface-container-lowest: '#060e1d'
  surface-container-low: '#141c2b'
  surface-container: '#18202f'
  surface-container-high: '#222a3a'
  surface-container-highest: '#2d3545'
  on-surface: '#dbe2f8'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#dbe2f8'
  inverse-on-surface: '#293041'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#44e2cd'
  on-secondary: '#003731'
  secondary-container: '#03c6b2'
  on-secondary-container: '#004d44'
  tertiary: '#ffb2b9'
  on-tertiary: '#67001f'
  tertiary-container: '#ea6479'
  on-tertiary-container: '#5b001a'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#62fae3'
  secondary-fixed-dim: '#3cddc7'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005047'
  tertiary-fixed: '#ffdadc'
  tertiary-fixed-dim: '#ffb2b9'
  on-tertiary-fixed: '#400010'
  on-tertiary-fixed-variant: '#891933'
  background: '#0b1322'
  on-background: '#dbe2f8'
  surface-variant: '#2d3545'
typography:
  display-score:
    fontFamily: Outfit
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 52px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Outfit
    fontSize: 15px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.04em
  label-md:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.06em
  label-sm:
    fontFamily: Outfit
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-mobile: 0.5rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style
The design system establishes a tranquil yet tactile arcade atmosphere: calm contemplation meets vibrant tactile feedback. Designed specifically for portrait-first mobile interactions, the aesthetic pairs midnight-deep celestial backdrops with glowing, luminous gems. The design movement blends **Tactile Glassmorphism** with **Atmospheric Game UI**—avoiding noisy skeuomorphism in favor of sleek, semi-translucent frosted slates, crisp luminous perimeter highlights, and jewel-like game tiles with soft internal bevels. The target audience seeks a premium, focused, and stress-free puzzle sanctuary that responds with rewarding micro-interactions under one-handed thumb navigation.

## Colors
The palette is built upon deep cosmic darkness layered with electric neon bioluminescence:
- **Foundations**: `#0B0F19` forms the primary canvas depth, paired with `#101827` and `#1E293B` for elevated frosted glass containers and HUD consoles.
- **Primary (Indigo)**: `#6366F1` (with highlight `#818CF8`) anchors the core brand identity, primary active controls, and central energy levels.
- **Secondary (Mint/Turquoise)**: `#2DD4BF` functions as the key success, score combo, and completion glow indicator.
- **Tertiary (Lively Coral / Amber Accents)**: `#FB7185` and `#FBBF24` serve as dynamic block color themes, high-stakes warning clears, and streak counters.
- **Neutrals & Text**: Pure slate neutrals ranging from `#334155` for inactive tile grids up to `#F8FAFC` for high-contrast, crystal-clear typography.

Glows and chromatic emissions must always remain restrained: use localized radial emissions (`rgba(45, 212, 191, 0.18)` or `rgba(99, 102, 241, 0.22)`) rather than overwhelming ambient washouts to preserve legibility and battery efficiency on OLED displays.

## Typography
The system employs `Outfit` for energetic, geometric numbers, titles, and HUD labels, alongside `Plus Jakarta Sans` for body copy, dialog descriptions, and accessible micro-copy. 

Numeric counters (such as scores, multipliers, and coin tallies) must always leverage tabular numeric figures (`font-variant-numeric: tabular-nums`) to prevent horizontal jitter during rapid tallying animations. Display scores use tight letter-spacing for athletic density, while micro-HUD badges use elevated letter-spacing and uppercase styling to maximize glanceability during gameplay.

## Layout & Spacing
This layout adopts a portrait-locked mobile architecture arranged into three vertical zones:
1. **Top HUD (Score, Level, Streak, Settings)**: Safe-area anchored, minimal vertical footprint (under 15% viewport height).
2. **Center Arena (The 8x8 or 10x10 Matrix)**: Square aspect-ratio container fitted with symmetrical margins (`margin-mobile: 1rem`) and rigid inner grid gaps (`space-xs: 0.25rem`).
3. **Bottom Tray (Block Selection Deck)**: Dedicated thumb-friendly ergonomic deck reserved for 3 draggable polyomino pieces, spaced generously with `space-md` gaps.

All horizontal layouts rely on compact gutters to prevent shrinking the active touch canvas on narrow devices (360dp–412dp). Vertical layouts prioritize comfortable thumb-reach zones in the bottom 45% of the screen.

## Elevation & Depth
Depth is created by layering dark semi-translucent glass panels above deep spatial backdrops:
- **Base Layer (Canvas)**: Solid `#0B0F19` with subtle multi-stop radial illumination centered behind the active game board.
- **Glassmorphic Panels (Surface Layer)**: Translucent `#101827` at 75% opacity, paired with an 18px backdrop blur (`backdrop-filter: blur(18px)`) and a delicate 1px border stroke (`rgba(255, 255, 255, 0.08)` top-lit gradient to `rgba(255, 255, 255, 0.02)` bottom).
- **Block Tiles (Tactile Objects)**: Non-flat surfaces featuring an inset bevel: top/left inner highlight `inset 0 1px 1px rgba(255, 255, 255, 0.35)` and bottom/right inner shadow `inset 0 -2px 2px rgba(0, 0, 0, 0.4)`. Dropshadows for floating/dragged pieces extend outward using a diffuse colored aura: `0 12px 24px -4px rgba(0, 0, 0, 0.6), 0 0 16px rgba(99, 102, 241, 0.35)`.
- **Modals & Overlays**: `#0B0F19` at 85% opacity with 24px backdrop blur, bordered with a 1px perimeter glow of `#818CF8`.

## Shapes
A unified rounded geometry is enforced across all game surfaces:
- Individual block tiles within tetrominoes and polyominoes use `rounded` (8px / `0.5rem`), creating a soft tactile pillowy silhouette without losing grid alignment.
- Grid slots on the main matrix feature matched internal curvature (`0.5rem`) with negative inset borders to cradle placed blocks.
- Action buttons, floating HUD pills, and status tags use `rounded-xl` or full pill geometry (`9999px`) to emphasize touch affordance and fingertip comfort.
- Main glass decks and score modules leverage `rounded-xl` (24px / `1.5rem`).

## Components

### 1. Game Block Tiles & Pieces
- **Empty Grid Cell**: Flat `#131D31` fill, subtle inset border `rgba(255, 255, 255, 0.04)`.
- **Active Placed Block**: Vibrant jewel fills (Indigo, Turquoise, Rose, or Amber) with 1px top-lit inner bevel highlight, subtle linear surface gradient, and 4px external edge radius.
- **Dragged Piece**: Scaled up to 1.1x under touch, positioned slightly above the thumb anchor point, radiating an accent-colored drop blur.

### 2. Buttons
- **Primary Game Button (Play / Claim / Revive)**: Full pill silhouette, saturated `#6366F1` with an inner top gloss highlight and bottom shadow creating physical pressability. Active state depresses 2px with an inner shadow and intensified turquoise edge glow.
- **Secondary Glass Button (Pause / Restart / Settings)**: Translucent `#1E293B` at 60% opacity, 1px perimeter stroke (`rgba(255, 255, 255, 0.12)`), housing an icon in `#F8FAFC`.
- **Tactile Feedback**: Every button press triggers a spring micro-scale animation (down to `0.96`, bouncing back to `1.0`).

### 3. HUD Score & Streak Badges
- **Score Counter**: Floating glass capsule at top center, housing `display-score` typography. Score updates pulse upward briefly with `#2DD4BF` numerals.
- **Combo / Streak Pill**: Pill shape with an amber-to-rose glowing gradient border, featuring an animated flame/spark icon beside compact `label-md` text.

### 4. Selection Deck (Polyomino Shelf)
- Located in the bottom thumb zone, displaying 3 queued block pieces centered on invisible soft-touch pads. The background is a unified dark frosted glass trough with soft upper shadow falloff.

### 5. Dialogs & Modals (Game Over / Level Clear)
- Centered cards with `rounded-xl` (24px) corners, frosted obsidian glass fill, top-lit indigo edge stroke, and celebratory particle emission behind the card perimeter. Primary action pill pinned to bottom full-width.