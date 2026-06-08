#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
mounts=$(docker service inspect --format '{{json .Spec.TaskTemplate.ContainerSpec.Mounts}}' market_db)
jq -e '.[] | select(.Type=="volume" and .Source=="market_db-data" and .Target=="/var/lib/postgresql/data")' <<<"$mounts" >/dev/null || fail "DB volume mount неверен"
docker volume inspect market_db-data >/dev/null || fail "Volume market_db-data отсутствует"
created=$(curl -fsS -X POST -H 'Content-Type: application/json' -d '{"item":"checker-persistence","quantity":11}' http://127.0.0.1:8080/orders)
id=$(jq -r '.id' <<<"$created"); old=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_db | head -1)
docker service update --force market_db >/dev/null
out=/tmp/capstone-persistence.json
rm -f "$out"
for _ in $(seq 1 90); do
  new=$(docker service ps --filter desired-state=running --format '{{.ID}}' market_db | head -1)
  [ -n "$new" ] && [ "$new" != "$old" ] && curl -fsS "http://127.0.0.1:8080/orders/$id" > "$out" 2>/dev/null && break
  sleep 2
done
[ -s "$out" ] || fail "API не восстановился после замены DB task"
jq -e --arg id "$id" '.id==$id and .item=="checker-persistence"' "$out" >/dev/null || fail "Данные потеряны после замены DB task"
rm -f "$out"
echo "OK: persistent state пережил замену DB task"
