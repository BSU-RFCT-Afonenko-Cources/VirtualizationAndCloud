#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
FILE="$LAB/evidence/incident.json"
test -s "$FILE" || { echo "Нет итогового incident.json"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]))
assert x.get('incident_id')=='compose-debugging-final', 'Неверный incident_id'
for key in ('root_causes','fixes'):
    assert isinstance(x.get(key),list) and len(x[key])>=3, f'{key}: нужно минимум три элемента'
    assert all(isinstance(v,str) and v.strip() for v in x[key]), f'{key}: элементы должны быть строками'
text=' '.join(x['root_causes']+x['fixes']).lower()
checks = {
    'dns': ('dns', 'upstream', 'имя', 'service name'),
    'health': ('health', 'провер', 'endpoint'),
    'memory': ('memory', 'памят', 'ресурс', 'limit'),
}
for marker, variants in checks.items():
    assert any(v in text for v in variants), f'Не отражена тема {marker}'
v=x.get('verification',{})
assert v.get('health')==200 and v.get('items')==200, 'HTTP verification должна содержать коды 200'
assert v.get('compose_status')=='healthy', 'compose_status должен быть healthy'
PY
for service in web api db; do
  cid="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q "$service")"
  test "$(docker inspect -f '{{.State.Health.Status}}' "$cid")" = healthy || { echo "$service не healthy"; exit 1; }
done
CID="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q api)"
[ "$(docker inspect -f '{{.HostConfig.Memory}}' "$CID")" -gt 0 ]
[ "$(docker inspect -f '{{.HostConfig.NanoCpus}}' "$CID")" -gt 0 ]
curl --fail --silent --max-time 5 http://127.0.0.1:8080/health >/dev/null
curl --fail --silent --max-time 5 http://127.0.0.1:8080/api/items >/dev/null
