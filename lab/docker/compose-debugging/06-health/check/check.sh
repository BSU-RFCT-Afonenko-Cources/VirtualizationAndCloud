#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
FILE="$LAB/evidence/health-inspect.json"
test -s "$FILE" || { echo "Нет health inspect evidence"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]))
h=x.get('Health',{})
assert h.get('Status') in {'starting','unhealthy'}, 'Evidence не фиксирует health failure'
logs=h.get('Log',[])
assert logs, 'Нет истории healthcheck'
assert any(int(r.get('ExitCode',0)) != 0 or r.get('Output') for r in logs), 'Нет диагностического результата healthcheck'
PY
grep -Eq 'API_HEALTH_PATH:[[:space:]]+/health$' "$LAB/compose.yaml" || { echo "Health endpoint не исправлен"; exit 1; }
for service in api web; do
  cid="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q "$service")"
  test "$(docker inspect -f '{{.State.Status}}' "$cid")" = running
  test "$(docker inspect -f '{{.State.Health.Status}}' "$cid")" = healthy || { echo "$service не healthy"; exit 1; }
done
