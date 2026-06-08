#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
python3 - <<'PY'
from pathlib import Path
p=Path('/home/ubuntu/compose-debugging/compose.yaml')
s=p.read_text()
if '    mem_limit: 192m\n' not in s:
    needle='  api:\n    build: ./api\n'
    s=s.replace(needle, needle+'    mem_limit: 192m\n    cpus: 0.50\n', 1)
p.write_text(s)
PY
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
"${COMPOSE[@]}" up -d --force-recreate --wait api web
for _ in $(seq 1 30); do curl --silent --max-time 3 'http://127.0.0.1:8080/api/load?seconds=0.2' >/dev/null & done
sleep 1
CID="$("${COMPOSE[@]}" ps -q api)"
docker stats --no-stream --format '{{json .}}' "$CID" > "$LAB/evidence/resource-stats.jsonl"
wait
curl --fail --silent --max-time 5 http://127.0.0.1:8080/api/items >/dev/null
chown ubuntu:ubuntu "$LAB/compose.yaml" "$LAB/evidence/resource-stats.jsonl"
