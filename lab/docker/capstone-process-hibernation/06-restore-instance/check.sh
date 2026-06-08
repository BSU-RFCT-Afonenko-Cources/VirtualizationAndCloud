#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation; E="${LAB}/evidence/restore.json"
[[ -f "${E}" ]] || { echo "Нет evidence/restore.json"; exit 1; }
python3 - "${E}" <<'PY'
import json,pathlib,subprocess,sys,urllib.request
x=json.loads(pathlib.Path(sys.argv[1]).read_text()); now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3))
cid=subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip(); pid=int(subprocess.check_output(['docker','inspect','-f','{{.State.Pid}}','hib-worker'],text=True))
assert x.get('mode') in ('criu','fallback')
assert x['old_container_id'] != x['new_container_id'] == cid
assert int(x['checkpoint_progress'])>0 and int(x['restored_progress'])>=int(x['checkpoint_progress'])
assert now['progress']>=x['restored_progress'] and int(x['pid'])==pid
assert x.get('proc_namespaces_checked') is True and pathlib.Path(f'/proc/{pid}/ns').is_dir()
expected='process-level' if x['mode']=='criu' else 'application-level'
assert x.get('recovery_classification')==expected
print('Новый runtime instance восстановлен без старта с нуля')
PY
