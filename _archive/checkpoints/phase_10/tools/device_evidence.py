"""Only the user's enumerated adb commands. No input/lifecycle injection."""
from pathlib import Path
import json,os,subprocess,sys,time

root=Path(__file__).resolve().parents[1]
out=root/'docs/device'
out.mkdir(parents=True,exist_ok=True)
adb='C:/Android/Sdk/platform-tools/adb.exe'
assert Path(os.environ['ANDROID_USER_HOME']).resolve()==root/'.android-user'
records=[]
def run(label,args,binary=False):
    result=subprocess.run([adb]+args,cwd=root,capture_output=True,timeout=180)
    records.append({'command':['adb']+args,'exit_code':result.returncode})
    payload=result.stdout
    if binary and payload.startswith(b'\x89PNG\r\r\n'):
        (out/(label+'.transport.bin')).write_bytes(payload)
        payload=payload.replace(b'\r\n',b'\n')
    (out/(label+('.png' if binary else '.txt'))).write_bytes(payload)
    if result.stderr:(out/(label+'.stderr.txt')).write_bytes(result.stderr)
    print(label+': exit '+str(result.returncode))
    if not binary and not label.startswith('logcat'):print(result.stdout.decode('utf-8',errors='replace')[:1200])
    return result
if '--passive' in sys.argv:
    run('app-screen',['shell','screencap','-p'],True)
    run('logcat-followup',['logcat','-d'])
    raise SystemExit(0)
probe=run('adb-devices',['devices'])
if '--collect' not in sys.argv:raise SystemExit(probe.returncode)
connected=[line for line in probe.stdout.decode().splitlines()[1:] if line.strip().endswith('\tdevice')]
if len(connected)!=1:
    (out/'status.json').write_text(json.dumps({'status':'BLOCKED(device)','reason':'Exactly one authorized, online device is required; found '+str(len(connected)),'commands':records},indent=2))
    raise SystemExit(0)
facts=json.loads((root/'build/evidence/android-final-facts.json').read_text())
installed=run('install',['install','-r','build\\lumiblock-debug.apk'])
if installed.returncode or b'Success' not in installed.stdout:
    (out/'status.json').write_text(json.dumps({'status':'BLOCKED(device install)','commands':records},indent=2))
    raise SystemExit(0)
launch=run('launch',['shell','am','start','-n',facts['package']+'/'+facts['launcher']])
time.sleep(3)
screen=run('launch-screen',['shell','screencap','-p'],True)
run('gfxinfo',['shell','dumpsys','gfxinfo',facts['package']])
run('meminfo',['shell','dumpsys','meminfo',facts['package']])
run('logcat',['logcat','-d'])
status={'status':'COLLECTED','commands':records,'package':facts['package'],'apk_sha256':facts['sha256'],'png_signature':(out/'launch-screen.png').read_bytes().startswith(b'\x89PNG\r\n\x1a\n'),'scope':'Install/launch and passive evidence only. No manual checklist tick inferred.'}
(out/'status.json').write_text(json.dumps(status,indent=2),encoding='utf-8')
