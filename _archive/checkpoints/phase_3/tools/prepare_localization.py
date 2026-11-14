"""Create Phase 3 English source keys. Non-English drafting is Phase 8."""
from pathlib import Path
import csv
import re

root = Path(__file__).resolve().parents[1]
prompt = (root / 'docs/MASTER_IMPLEMENTATION_PROMPT.md').read_text(encoding='utf-8-sig')
section = prompt.split('### 10.5 English source strings')[1].split('## 11.')[0]
strings = {}
for line in section.splitlines():
    matches = list(re.finditer(r'(?<!\S)([a-z][a-z0-9_.]*)=', line))
    for index, match in enumerate(matches):
        end = matches[index+1].start() if index+1 < len(matches) else len(line)
        strings[match.group(1)] = line[match.end():end].strip()
for i, month in enumerate(('January February March April May June July August September October November December').split(), 1):
    strings[f'month.{i}'] = month
locales = ['en','tr','es','pt-BR','fr','de','it','ja','ko','zh-CN','ar','hi','id','vi','ru','th']
with (root/'localization/strings.csv').open('w',encoding='utf-8',newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['keys']+locales)
    for key, value in strings.items():
        writer.writerow([key]+[value]*len(locales))
print(f'{len(strings)} source keys; 16 locale columns (English placeholders outside en until Phase 8)')
