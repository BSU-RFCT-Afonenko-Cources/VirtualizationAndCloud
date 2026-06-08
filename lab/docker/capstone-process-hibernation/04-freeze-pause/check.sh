#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/capstone-process-hibernation/evidence/freeze.json
[[ -f "${E}" ]] || { echo "Нет evidence/freeze.json"; exit 1; }
python3 - "${E}" <<'PY'
import json,pathlib,subprocess,sys,urllib.request
x=json.loads(pathlib.Path(sys.argv[1]).read_text())
required=['container_id','instance_id','pid','progress_before','progress_during','progress_after','docker_paused_observed','cgroup_frozen_observed','resumed']
assert all(k in x for k in required), 'Evidence неполон'
assert x['progress_before']==x['progress_during'], 'Progress изменился во время pause'
assert x['progress_after']>x['progress_during'], 'Progress не продолжился после unpause'
assert x['docker_paused_observed'] is True and x['cgroup_frozen_observed'] is True and x['resumed'] is True
now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status',timeout=3))
assert now['instance_id']==x['instance_id'] and now['progress']>=x['progress_after']
assert subprocess.check_output(['docker','inspect','-f','{{.State.Paused}}','hib-worker'],text=True).strip()=='false'
print('Pause/freeze и resume доказаны')
PY
