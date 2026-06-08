#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
curl -fsS -X POST http://127.0.0.1:18080/quiesce >/dev/null; sleep 1
tar -C "${LAB}/data" -czf "${LAB}/backups/hib-data.tar.gz" queue.txt progress.json events.log
(cd "${LAB}/backups" && sha256sum hib-data.tar.gz > hib-data.tar.gz.sha256)
python3 - <<'PY'
import hashlib,json,pathlib,time,urllib.request
lab=pathlib.Path('/home/ubuntu/capstone-process-hibernation'); a=lab/'backups/hib-data.tar.gz'; s=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
m={'archive':'hib-data.tar.gz','sha256':hashlib.sha256(a.read_bytes()).hexdigest(),'files':['queue.txt','progress.json','events.log'],'size_bytes':a.stat().st_size,'instance_id':s['instance_id'],'progress':s['progress'],'timestamp':time.time(),'quiesced':s['quiesced']}
(lab/'backups/manifest.json').write_text(json.dumps(m,indent=2,sort_keys=True))
PY
chown -R ubuntu:ubuntu "${LAB}/backups"
