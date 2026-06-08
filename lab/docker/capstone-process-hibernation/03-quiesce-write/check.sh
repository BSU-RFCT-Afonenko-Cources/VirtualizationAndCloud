#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
E="${LAB}/evidence/pre-checkpoint.json"
[[ -f "${E}" && -f "${LAB}/data/progress.json" ]] || { echo "Нет pre-checkpoint evidence или progress.json"; exit 1; }
python3 - "${E}" "${LAB}/data/progress.json" <<'PY'
import hashlib,json,pathlib,subprocess,sys,time,urllib.request
e=json.loads(pathlib.Path(sys.argv[1]).read_text()); p=pathlib.Path(sys.argv[2]); disk=json.loads(p.read_text())
now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3)); time.sleep(1.2)
again=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3))
cid=subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip()
pid=int(subprocess.check_output(['docker','inspect','-f','{{.State.Pid}}','hib-worker'],text=True))
assert now.get('quiesced') is True and again.get('quiesced') is True and e.get('quiesced') is True
assert now['progress']==again['progress']==disk['progress']==e['progress'], 'Progress не согласован'
assert e['container_id']==cid and e['instance_id']==now['instance_id'] and int(e['pid'])==pid
assert e['progress_sha256']==hashlib.sha256(p.read_bytes()).hexdigest()
assert e.get('timestamp'), 'Нет timestamp'
print('Запись согласованно остановлена')
PY
