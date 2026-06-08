#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
curl -fsS -X POST http://127.0.0.1:18080/quiesce >/dev/null
sleep 1
python3 - <<'PY'
import hashlib,json,pathlib,subprocess,time,urllib.request
lab=pathlib.Path('/home/ubuntu/capstone-process-hibernation'); p=lab/'data/progress.json'
s=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
e={'container_id':subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip(),'instance_id':s['instance_id'],'progress':s['progress'],'progress_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'quiesced':s['quiesced'],'timestamp':time.time(),'pid':int(subprocess.check_output(['docker','inspect','-f','{{.State.Pid}}','hib-worker'],text=True))}
(lab/'evidence/pre-checkpoint.json').write_text(json.dumps(e,indent=2,sort_keys=True))
PY
chown -R ubuntu:ubuntu "${LAB}/evidence"
