#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
MODE=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/evidence/checkpoint.json"))["mode"])')
OLD=$(docker inspect -f '{{.Id}}' hib-worker 2>/dev/null || python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/evidence/pre-checkpoint.json"))["container_id"])')
CP=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/evidence/checkpoint.json"))["progress"])')
docker rm -f hib-worker >/dev/null 2>&1 || true
if [[ "${MODE}" == criu ]]; then
  docker create --name hib-worker --hostname hib-status -p 127.0.0.1:18080:8080 -v "${LAB}/data:/data" hib-worker:lab >/dev/null
  docker start --checkpoint-dir "${LAB}/checkpoints" --checkpoint hib-checkpoint hib-worker >/dev/null
fi
if [[ "${MODE}" == fallback ]]; then
  docker run -d --name hib-worker --hostname hib-status -p 127.0.0.1:18080:8080 -v "${LAB}/data:/data" hib-worker:lab >/dev/null
fi
for _ in $(seq 1 30); do curl -fsS -X POST http://127.0.0.1:18080/resume >/dev/null 2>&1 && break; sleep 1; done
sleep 1
NEW=$(docker inspect -f '{{.Id}}' hib-worker); PID=$(docker inspect -f '{{.State.Pid}}' hib-worker)
python3 - "${MODE}" "${OLD}" "${NEW}" "${CP}" "${PID}" <<'PY'
import json,pathlib,sys,time,urllib.request
mode,old,new,cp,pid=sys.argv[1:]; now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
x={'mode':mode,'old_container_id':old,'new_container_id':new,'checkpoint_progress':int(cp),'restored_progress':now['progress'],'restored_instance_id':now['instance_id'],'pid':int(pid),'proc_namespaces_checked':pathlib.Path(f'/proc/{pid}/ns').is_dir(),'namespace_entries':sorted(p.name for p in pathlib.Path(f'/proc/{pid}/ns').iterdir()),'recovery_classification':'process-level' if mode=='criu' else 'application-level','timestamp':time.time()}
pathlib.Path('/home/ubuntu/capstone-process-hibernation/evidence/restore.json').write_text(json.dumps(x,indent=2,sort_keys=True))
PY
chown ubuntu:ubuntu "${LAB}/evidence/restore.json"
