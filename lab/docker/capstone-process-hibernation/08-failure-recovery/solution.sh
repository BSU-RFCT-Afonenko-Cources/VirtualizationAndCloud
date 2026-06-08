#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
BEFORE=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/data/progress.json"))["progress"])')
START=$(date +%s.%N)
docker rm -f hib-worker >/dev/null
rm -f "${LAB}/data/progress.json" "${LAB}/data/events.log"
(cd "${LAB}/backups" && sha256sum -c hib-data.tar.gz.sha256 >/dev/null)
tar -C "${LAB}/data" -xzf "${LAB}/backups/hib-data.tar.gz"
RESTORED=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/data/progress.json"))["progress"])')
printf '{"mode":"run"}\n' > "${LAB}/data/control.json"
docker run -d --name hib-worker --hostname hib-status -p 127.0.0.1:18080:8080 -v "${LAB}/data:/data" hib-worker:lab >/dev/null
for _ in $(seq 1 30); do curl -fsS http://127.0.0.1:18080/hib-status >/dev/null 2>&1 && break; sleep 1; done
sleep 2
END=$(date +%s.%N); NEW=$(docker inspect -f '{{.Id}}' hib-worker)
python3 - "${BEFORE}" "${RESTORED}" "${START}" "${END}" "${NEW}" <<'PY'
import json,pathlib,sys,time,urllib.request
before,restored,start,end,new=sys.argv[1:]; now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
x={'failure_type':'runtime-removal-and-working-state-loss','downtime_seconds':float(end)-float(start),'checksum_verified':True,'progress_before_failure':int(before),'progress_after_restore':int(restored),'progress_after_resume':now['progress'],'new_container_id':new,'http_status':200,'state_json_valid':True,'timestamp':time.time()}
pathlib.Path('/home/ubuntu/capstone-process-hibernation/evidence/recovery.json').write_text(json.dumps(x,indent=2,sort_keys=True))
PY
chown -R ubuntu:ubuntu "${LAB}"
