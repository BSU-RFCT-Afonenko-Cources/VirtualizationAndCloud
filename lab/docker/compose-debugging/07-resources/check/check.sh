#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
FILE="$LAB/evidence/resource-stats.jsonl"
test -s "$FILE" || { echo "Нет resource stats evidence"; exit 1; }
python3 - "$FILE" <<'PY'
import json,sys
rows=[json.loads(line) for line in open(sys.argv[1]) if line.strip()]
assert rows, 'Пустой snapshot'
r=rows[0]
assert r.get('CPUPerc') or r.get('CPU %'), 'Нет CPU metric'
assert r.get('MemUsage') or r.get('MemUsage / Limit'), 'Нет memory metric'
PY
CID="$(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q api)"
MEM="$(docker inspect -f '{{.HostConfig.Memory}}' "$CID")"
CPU="$(docker inspect -f '{{.HostConfig.NanoCpus}}' "$CID")"
OOM="$(docker inspect -f '{{.State.OOMKilled}}' "$CID")"
[ "$MEM" -ge 134217728 ] && [ "$MEM" -le 268435456 ] || { echo "Memory limit вне диапазона 128-256 MiB"; exit 1; }
[ "$CPU" -gt 0 ] && [ "$CPU" -le 1000000000 ] || { echo "CPU limit отсутствует или больше 1 CPU"; exit 1; }
[ "$OOM" = false ] || { echo "API завершался по OOM"; exit 1; }
test "$(docker inspect -f '{{.State.Health.Status}}' "$CID")" = healthy
curl --fail --silent --max-time 5 http://127.0.0.1:8080/api/items >/dev/null
