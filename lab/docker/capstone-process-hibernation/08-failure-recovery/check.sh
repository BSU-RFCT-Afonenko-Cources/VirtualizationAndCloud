#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation; E="${LAB}/evidence/recovery.json"
[[ -f "${E}" ]] || { echo "Нет evidence/recovery.json"; exit 1; }
(cd "${LAB}/backups" && sha256sum -c hib-data.tar.gz.sha256 >/dev/null)
python3 - "${E}" "${LAB}/data/progress.json" <<'PY'
import json,pathlib,subprocess,sys,time,urllib.request
x=json.loads(pathlib.Path(sys.argv[1]).read_text()); disk=json.loads(pathlib.Path(sys.argv[2]).read_text()); now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3))
required=['failure_type','downtime_seconds','checksum_verified','progress_before_failure','progress_after_restore','progress_after_resume','new_container_id','http_status','state_json_valid']
assert all(k in x for k in required)
assert x['checksum_verified'] is True and x['state_json_valid'] is True and int(x['http_status'])==200
assert float(x['downtime_seconds'])>0 and x['progress_after_restore']>=0 and x['progress_after_resume']>x['progress_after_restore']
cid=subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip(); assert cid==x['new_container_id']
assert disk['progress']==now['progress'] and now['progress']>=x['progress_after_resume']
print('Recovery drill завершён, endpoint и progress восстановлены')
PY
