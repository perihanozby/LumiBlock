"""Optional fontTools subsetter. No dependency installation or network access."""
from pathlib import Path
import csv, shutil, subprocess
root=Path(__file__).resolve().parents[1]
exe=shutil.which('pyftsubset')
if not exe: raise SystemExit('BLOCKED(fontTools): pyftsubset is unavailable; no dependency installed')
rows=list(csv.DictReader((root/'localization/strings.csv').open(encoding='utf-8')))
for locale,family in [('ja','JP'),('ko','KR'),('zh-CN','SC')]:
    source=root/f'assets/fonts/NotoSans{family}.full.ttf'
    if not source.exists():
        print('BLOCKED(font): missing',source)
        continue
    text=''.join(row[locale] for row in rows)+''.join(chr(i) for i in range(32,127))
    chars=root/f'.runtime/{family}-characters.txt'
    chars.parent.mkdir(parents=True,exist_ok=True)
    chars.write_text(text,encoding='utf-8')
    subprocess.run([exe,str(source),f'--text-file={chars}','--layout-features=*',f'--output-file={root}/assets/fonts/NotoSans{family}.ttf'],check=True)
