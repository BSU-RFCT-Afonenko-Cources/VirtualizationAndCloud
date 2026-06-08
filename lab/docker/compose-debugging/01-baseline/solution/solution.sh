#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
"${COMPOSE[@]}" up -d --build --wait
python3 - <<'PY'
import json, subprocess
lab='/home/ubuntu/compose-debugging'
services=[]
for service in ('web','api','db'):
    cid=subprocess.check_output(['docker','compose','-p','web-api-db','-f',f'{lab}/compose.yaml','ps','-q',service], text=True).strip()
    state=json.loads(subprocess.check_output(['docker','inspect',cid], text=True))[0]['State']
    services.append({'service':service,'state':state['Status'],'health':state.get('Health',{}).get('Status','none')})
with open(f'{lab}/evidence/baseline.json','w') as f:
    json.dump({'services':services},f,indent=2)
PY
chown ubuntu:ubuntu "$LAB/evidence/baseline.json"
