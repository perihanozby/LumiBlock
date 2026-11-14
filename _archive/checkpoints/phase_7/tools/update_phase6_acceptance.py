from pathlib import Path
import re

root=Path(__file__).resolve().parents[1]
matrix=root/'docs/ACCEPTANCE_MATRIX.md'
core='[core log](../build/evidence/phase6-final-core.stdout)'
ui='[desktop UI log](../build/evidence/phase6-final-ui.stdout)'
pack='[review pack](review/REVIEW_PACK_1/index.md)'
passes={f'C-{i:02d}':core for i in range(1,13)}
passes['C-10']='[previously executed 10,000-game balance](BALANCE_REPORT.md); retained baseline, not rerun for UI-only changes'
passes.update({f'S-{i:02d}':core for i in range(1,8)})
passes.update({f'I-{i:02d}':ui for i in range(2,8)})
passes['I-01']=core
for i in [3,4,5,6,7,9,10,11,12]: passes[f'U-{i:02d}']=ui
for i in [1,2]: passes[f'V-{i:02d}']=core+'; [colour values](../build/evidence/palette-math.txt)'
passes['V-03']=core+'; [byte-identical rebake](../build/evidence/atlas-determinism.txt)'
passes['V-04']='[45 captured states](review/REVIEW_PACK_1/cube_states.png); renderer states, not animated FX acceptance'
passes['V-08']=ui+'; font-size contract and minimum 12; built-in font fallback disclosed'
for i in [1,2,3]: passes[f'L-{i:02d}']=core+'; structural English/source-registration checks; non-English completion is Phase 8'
passes['L-04']=ui+'; 16 live core-navigation locale switches; full content completion remains Phase 8'
for i in [1,6]: passes[f'P-{i:02d}']=ui+'; zero idle invalidations and no Resource growth across repeated board draws'
blocked={
 'S-08':ui+'; desktop pause/flush verified; physical process/lifecycle tests require device approval',
 'I-08':'Physical phone drag feel not authorized or tested',
 'I-09':'Physical phone latency/feel not authorized or tested',
 'I-10':ui+'; router back matrix tested; Android OS portion requires device approval',
 'U-01':ui+'; automated behaviour PASS; human layout review pending '+pack,
 'U-02':ui+'; automated HUD/input PASS; human review pending '+pack,
 'U-13':ui+'; seven actual Control sizes, square boards, targets and horizontal bounds checked; human overlap review pending '+pack,
 'U-14':ui+'; injected cutouts checked; actual phone insets/log require device approval',
 'V-05':'56/64 dense-board capture ready; human legibility confirmation pending '+pack,
 'V-06':'Golden set cannot be created until written visual approval; no pixel-regression result claimed',
 'V-07':'Human Design Review #1 requested; no approval yet: '+pack,
 'V-09':'1.15 scale captures ready; human clipping/overlap review pending '+pack,
 'L-05':'Official font download could not connect; [font fallback and instructions](FONTS.md)',
 'L-09':'Machine drafts/staging disclosed; no native review',
 'A-05':'Generated audio and human listening approval still required in Phase 7',
 'A-06':'Physical vibration not authorized or tested',
 'P-02':ui+'; desktop drawing below 1.5 ms; phone measurement requires approval',
 'P-03':'Physical phone performance not authorized or tested',
 'P-05':'Physical phone cold-start timing not authorized or tested',
 'N-06':'No device install/launch authorization; no command executed',
 'N-07':'No device lifecycle authorization; no command executed',
 'N-08':'Physical notch/gesture review not authorized or tested',
 'N-10':'No device logcat/play authorization; no command executed',
}
pending={
 'U-08':ui+'; state, actual bus mute/volume, theme, assist/marks wiring tested; full audio/haptic/FX observability is Phase 7 (phase-order dependency recorded in CODEX_PROGRESS)',
 'L-06':'Home Arabic direction captured; complete Arabic screens/shaping review is Phase 8',
 'L-07':core+'; grouping tested; complete per-locale date/duration content is Phase 8',
}
lines=[]
for line in matrix.read_text(encoding='utf-8-sig').splitlines():
    match=re.match(r'\| ([A-Z]-\d\d) \|',line)
    if match:
        key=match.group(1)
        status,evidence=(('PASS',passes[key]) if key in passes else ('BLOCKED',blocked[key]) if key in blocked else ('NOT RUN',pending[key]) if key in pending else (None,None))
        if status:
            line=re.sub(r'\| (?:NOT RUN|PASS|FAIL|BLOCKED) \|[^|]*\|$',f'| {status} | {evidence} |',line)
    lines.append(line)
matrix.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Phase 6 acceptance evidence reconciled; visual/device claims remain blocked')
