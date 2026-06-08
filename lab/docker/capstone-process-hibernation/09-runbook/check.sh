#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation; FILE=""
for c in "${LAB}/runbook.json" "${LAB}/runbook.yaml" "${LAB}/runbook.yml"; do [[ -f "${c}" ]] && FILE="${c}" && break; done
[[ -n "${FILE}" ]] || { echo "Нет runbook.json, runbook.yaml или runbook.yml"; exit 1; }
python3 - "${FILE}" "${LAB}" <<'PY'
import json,pathlib,subprocess,sys,urllib.request
p=pathlib.Path(sys.argv[1]); lab=pathlib.Path(sys.argv[2])
if p.suffix=='.json': data=json.loads(p.read_text())
else:
    try: import yaml
    except ImportError: raise SystemExit('Для проверки YAML требуется PyYAML; используйте JSON')
    data=yaml.safe_load(p.read_text())
for k in ('mode','definitions','artifacts','environment_limitations','prerequisites','recovery_procedure','success_criteria','final_state','recovery_level'):
    assert k in data, f'Нет поля {k}'
assert data['mode'] in ('criu','fallback') and data['recovery_level'] in ('process-level','application-level')
assert {'freeze','checkpoint','restore','backup'} <= set(data['definitions'])
assert isinstance(data['recovery_procedure'],list) and len(data['recovery_procedure'])>=3
assert isinstance(data['success_criteria'],list) and data['success_criteria']
for item in data['artifacts']:
    assert (lab/item).exists(), f'Нет artifact {item}'
now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3)); cid=subprocess.check_output(['docker','inspect','-f','{{.Id}}','hib-worker'],text=True).strip()
f=data['final_state']; assert f['instance_id']==now['instance_id'] and f['container_id']==cid and int(f['progress'])<=now['progress']
print('Runbook соответствует фактическим artifacts и состоянию')
PY
