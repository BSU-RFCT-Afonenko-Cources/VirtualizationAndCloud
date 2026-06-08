#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
curl -fsS -X POST http://127.0.0.1:18080/resume >/dev/null
sleep 1
python3 - <<'PY'
import json,urllib.request,pathlib
path=pathlib.Path('/tmp/hib-freeze-before.json'); path.write_text(json.dumps(json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))))
PY
CID=$(docker inspect -f '{{.Id}}' hib-worker); PID=$(docker inspect -f '{{.State.Pid}}' hib-worker)
docker pause hib-worker >/dev/null
PAUSED=$(docker inspect -f '{{.State.Paused}}' hib-worker)
FROZEN=false
CGROUP=$(awk -F: '$1=="0"{print $3}' "/proc/${PID}/cgroup")
if [[ -r "/sys/fs/cgroup${CGROUP}/cgroup.freeze" ]] && [[ "$(cat "/sys/fs/cgroup${CGROUP}/cgroup.freeze")" == 1 ]]; then FROZEN=true; fi
BEFORE=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/data/progress.json"))["progress"])')
sleep 2
DURING=$(python3 -c 'import json; print(json.load(open("/home/ubuntu/capstone-process-hibernation/data/progress.json"))["progress"])')
docker unpause hib-worker >/dev/null
sleep 2
python3 - "${LAB}/evidence/freeze.json" "${CID}" "${PID}" "${BEFORE}" "${DURING}" "${PAUSED}" "${FROZEN}" <<'PY'
import json,pathlib,sys,urllib.request
now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status'))
x={'container_id':sys.argv[2],'instance_id':now['instance_id'],'pid':int(sys.argv[3]),'progress_before':int(sys.argv[4]),'progress_during':int(sys.argv[5]),'progress_after':now['progress'],'docker_paused_observed':sys.argv[6]=='true','cgroup_frozen_observed':sys.argv[7]=='true','resumed':True}
pathlib.Path(sys.argv[1]).write_text(json.dumps(x,indent=2,sort_keys=True))
PY
chown ubuntu:ubuntu "${LAB}/evidence/freeze.json"
