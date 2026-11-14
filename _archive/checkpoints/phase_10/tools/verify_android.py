"""Read-only APK verification. Requires tools/environment.ps1 environment."""
from pathlib import Path
import hashlib,json,re,struct,subprocess,zipfile

root=Path(__file__).resolve().parents[1]
apk=root/'build/lumiblock-debug.apk'
out=root/'build/evidence'
sdk=Path('C:/Android/Sdk/build-tools/35.0.0')
def run(name,args):
    result=subprocess.run(args,capture_output=True)
    text=(result.stdout+result.stderr).decode('utf-8',errors='replace')
    (out/f'android-final-{name}.txt').write_text(text,encoding='utf-8')
    print(f'{name}: exit {result.returncode}')
    if result.returncode: raise SystemExit(text)
    return text
badging=run('badging',[str(sdk/'aapt.exe'),'dump','badging',str(apk)])
permissions=run('permissions',[str(sdk/'aapt.exe'),'dump','permissions',str(apk)])
manifest=run('manifest',[str(sdk/'aapt.exe'),'dump','xmltree',str(apk),'AndroidManifest.xml'])
signature=run('signature',['cmd','/c',str(sdk/'apksigner.bat'),'verify','--verbose',str(apk)])
alignment=run('alignment',[str(sdk/'zipalign.exe'),'-c','-P','16','-v','4',str(apk)])
assert "name='com.perih.lumiblock'" in badging
assert "versionCode='2'" in badging and "versionName='0.2.0'" in badging
assert "targetSdkVersion:'36'" in badging
assert "native-code: 'arm64-v8a'" in badging and 'android.hardware.screen.portrait' in badging
assert 'android.permission.VIBRATE' in permissions and 'android.permission.INTERNET' not in permissions
assert 'Verified using v2 scheme (APK Signature Scheme v2): true' in signature
assert 'Verified using v3 scheme (APK Signature Scheme v3): true' in signature
assert apk.stat().st_size<=32*1024*1024,'APK exceeds 32 MiB'
alias=re.search(r'E: activity-alias.*?android:name[^=]*="([^"]+)".*?android.intent.category.LAUNCHER',manifest,re.S)
assert alias,'No manifest-proven launcher alias'
z=zipfile.ZipFile(apk)
names=z.namelist()
(out/'android-final-entries.txt').write_text('\n'.join(names),encoding='utf-8')
for prefix in ['design/','docs/','tests/','tools/','_archive/','build/','android/','.runtime/']:
    assert not any(n.startswith('assets/'+prefix) for n in names),prefix
assert not any(n.startswith('assets/scripts/main.gd') or n.startswith('assets/scenes/main.tscn') for n in names)
assert not any(n.endswith('.csv') or n.endswith('.md') for n in names)
assert 'assets/assets/fonts/manifest.json' in names
assert len([n for n in names if n.startswith('assets/assets/fonts/LICENSES/') and n.endswith('.txt')])==7
elf=[]
for name in names:
    if not name.endswith('.so'):continue
    data=z.read(name)
    header=struct.unpack_from('<16sHHIQQQIHHHHHH',data)
    loads=[]
    for i in range(header[10]):
        p=struct.unpack_from('<IIQQQQQQ',data,header[5]+i*header[9])
        if p[0]==1:
            assert p[7]>=16384 and (p[2]-p[3])%16384==0,(name,p)
            loads.append(p[7])
    elf.append({'library':name,'load_alignments':loads})
facts={'package':'com.perih.lumiblock','launcher':alias.group(1),'version':'0.2.0','version_code':2,'target_api':36,'min_api':24,'abi':'arm64-v8a','permissions':['android.permission.VIBRATE'],'bytes':apk.stat().st_size,'MiB':apk.stat().st_size/1024**2,'sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),'zipalign_16k':True,'elf':elf,'signature_v2_v3':True,'export_filter':True}
(out/'android-final-facts.json').write_text(json.dumps(facts,indent=2),encoding='utf-8')
print(json.dumps(facts,indent=2))
