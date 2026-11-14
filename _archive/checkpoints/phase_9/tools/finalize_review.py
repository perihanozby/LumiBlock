from pathlib import Path

root=Path(__file__).resolve().parents[1]
folder=root/'docs/review/REVIEW_PACK_1'
intro='''# Human Design Review 1

Please approve this visual direction or list specific changes. Review small-screen fit, hierarchy, cube treatment, dense-board legibility, typography and modal appearance. Written approval is required by MASTER_IMPLEMENTATION_PROMPT.md §14.4 before visual acceptance or a golden baseline.

## Start here

- [Home, 390×844](home_390x844.png) · [Home, 360×640](home_360x640.png)
- [Game, 56/64 occupied](game_dense_390x844.png)
- [Valid ghost](game_valid_ghost_390x844.png) · [Invalid ghost](game_invalid_ghost_390x844.png)
- [Pause](pause_390x844.png) · [Confirmation](confirm_390x844.png) · [Game Over](game_over_390x844.png)
- [Settings top](settings_390x844.png) · [Settings bottom](settings_bottom_390x844.png)
- [Tutorial target](tutorial_360x640.png) · [Tutorial explanation](tutorial_step2_360x640.png)
- [Larger text Home](home_scale115_390x844.png) · [Larger text Settings](settings_scale115_390x844.png) · [Larger text Game Over](game_over_scale115_390x844.png)
- [45 cube states](cube_states.png)
- [16-locale contact sheet](locale_contact_sheet.png)

Contact-sheet rows: en / tr / es / pt-BR; fr / de / it / ja; ko / zh-CN / ar / hi; id / vi / ru / th.

## Limits disclosed before approval

- These are real desktop OpenGL captures of deterministic fixtures, not physical-phone results or real player records.
- Built-in/system fonts are used because the authorized official Manrope download could not connect. Manrope/Noto coverage remains BLOCKED(font).
- Core navigation strings are machine-drafted in 16 locales; remaining text is English staging until Phase 8. No native translation approval is claimed.
- Audio assets, full haptic patterns and animated effects are Phase 7 work. Settings bus/state/theme wiring is tested, but the current build is not claimed to provide final sound/vibration/effects.
- Phone drag feel, safe areas, performance and vibration still require explicit device authorization and testing.
- The required RGBA atlas plus mipmaps occupies about 2 MiB, exceeding the stated 1.6 MiB uncompressed budget. This remains unresolved; desktop draw-time checks passed.
- No golden screenshot set has been created. Visual quality is BLOCKED until you review it.

## Measured colour values

'''
palette=(root/'build/evidence/palette-math.txt').read_text(encoding='utf-8-sig')
files=sorted(p.name for p in folder.glob('*.png'))
body=intro+'```text\n'+palette+'\n```\n\n## All captures\n\n'
body+=f'{len(files)} PNG artifacts: 158 screen captures, the cube sheet and the locale contact sheet. Seven viewport sizes and 1.15 text-scale samples are included.\n\n'
body+='\n'.join(f'- [{name}]({name})' for name in files)+'\n'
(folder/'index.md').write_text(body,encoding='utf-8')
print(f'Review index finalized: {len(files)} PNG artifacts')
