> Historical prototype report. This is not current-session acceptance evidence. See [CODEX_PROGRESS.md](CODEX_PROGRESS.md) and [ACCEPTANCE_MATRIX.md](ACCEPTANCE_MATRIX.md) for the current implementation and executed results.

# LumiBlock — Luminous Cubes Design System

## Direction

LumiBlock uses a focused midnight-celestial canvas with restrained atmospheric light and tactile luminous cubes. The cube renderer is shared by board cells, tray pieces and drag previews so the logical and visual representations stay coherent.

## Tokens

| Token | Value | Use |
|---|---|---|
| `canvas` | `#0B1322` | Main background |
| `panel` | `#18202F` | Frosted dark surfaces |
| `empty_cell` | `#131D31` | Board sockets |
| `indigo` | `#8083FF` | Primary navigation and daily mode |
| `turquoise` | `#44E2CD` | Confirmed actions and score feedback |
| `coral` | `#FF7188` | Invalid state and warning feedback |
| `amber` | `#FBBF24` | Accent cube family |
| `text` | `#DBE2F8` | Primary text |
| `muted_text` | `#C7C4D7` | Secondary text |

## Interaction tokens

- Primary touch target: 48 dp minimum.
- Placement preview: same cell geometry as the board, alpha 0.72.
- Drag lift: 58 px above the pointer, with the same cube renderer as the tray.
- Invalid preview: coral tint; invalid release never mutates the board.
- Board cell: 39 px visible surface with a 4 px grid pitch.
- Motion should remain short and reversible; reduced-effects settings should remove atmospheric pulses before disabling gameplay feedback.

## Accessibility

The palette separates occupied cells by hue and luminance, and invalid state uses coral plus placement rejection rather than color alone. Text remains high contrast against the midnight canvas. Localization resources include Arabic, but RTL layout review and native-speaker review remain release tasks.

