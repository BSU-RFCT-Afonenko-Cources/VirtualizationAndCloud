#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
FILE="$LAB/evidence/baseline.json"
test -f "$FILE" || { echo "Нет $FILE"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]))
rows={r.get('service'):r for r in x.get('services',[])}
for name in ('web','api','db'):
    assert name in rows, f'В baseline отсутствует {name}'
    assert rows[name].get('state')=='running', f'{name}: state не running'
    assert rows[name].get('health')=='healthy', f'{name}: health не healthy'
PY
for service in web api db; do
  cid="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q "$service")"
  test -n "$cid" || { echo "Нет контейнера $service"; exit 1; }
  test "$(docker inspect -f '{{.State.Status}}' "$cid")" = running
  test "$(docker inspect -f '{{.State.Health.Status}}' "$cid")" = healthy
done
curl --fail --silent --max-time 5 http://127.0.0.1:8080/api/items >/dev/null
