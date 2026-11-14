"""Build-only local subsetting; never transmits translation text or font data."""
from pathlib import Path
import csv, json, shutil, sys
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root/'.runtime/font-tools'))
from fontTools import subset
from fontTools.ttLib import TTFont
rows=list(csv.DictReader((root/'localization/strings.csv').open(encoding='utf-8')))
manifest=json.loads((root/'assets/fonts/manifest.json').read_text(encoding='utf-8-sig'))
native={'Arabic':'???????','Devanagari':'??????','Thai':'???','JP':'???','KR':'???','SC':'????'}
locales={'Arabic':'ar','Devanagari':'hi','Thai':'th','JP':'ja','KR':'ko','SC':'zh-CN'}
archive=root/'_archive/font_sources'
archive.mkdir(parents=True,exist_ok=True)
before=after=0
for family,paths in manifest.items():
    chars=set(''.join(row[locales[family]] for row in rows)+native[family]+''.join(chr(i) for i in range(32,127))+'?????????')
    for resource in paths:
        dest=root/resource.removeprefix('res://')
        source=archive/dest.name
        if not source.exists(): shutil.copy2(dest,source)
        if family=='Thai':
            before+=source.stat().st_size
            shutil.copy2(source,dest)
            after+=dest.stat().st_size
            continue
        font=TTFont(source,recalcBBoxes=False,recalcTimestamp=False)
        before+=source.stat().st_size
        options=subset.Options()
        options.layout_features=['*']
        options.name_IDs=['*']
        options.name_legacy=True
        options.name_languages=['*']
        sub=subset.Subsetter(options=options)
        sub.populate(unicodes=[ord(c) for c in chars])
        sub.subset(font)
        # Modified fonts use a distinct family; copyright/OFL notices remain intact.
        for record in font['name'].names:
            if record.nameID in (1,4,6,16):
                value='LumiBlockNoto'+family+'Subset' if record.nameID==6 else 'LumiBlock Noto '+family+' Subset'
                record.string=value.encode(record.getEncoding(),errors='replace')
        font.flavor='woff2'
        font.save(dest)
        font.close()
        after+=dest.stat().st_size
print(f'Local official-font subsets: {before} -> {after} bytes; full originals archived; all layout features retained')
(root/'build/evidence/font-subsets.txt').write_text(f'fontTools4.68.0 + Brotli1.2.1,local-only. Noto sources {before}bytes -> bundled files {after}bytes; Thai shards retained unmodified. Manrope remains full. Original OFLs retained; modified family names LumiBlock Noto ... Subset. Coverage/UI/shaping regression required after import.\n',encoding='utf-8')
