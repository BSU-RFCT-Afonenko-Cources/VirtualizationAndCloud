#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
e=/home/ubuntu/capstone-swarm/evidence/recovery.json
old=$(jq -r '.removed_task' "$e"); new=$(jq -r '.replacement_task' "$e")
[ -n "$old" ] && [ -n "$new" ] && [ "$old" != "$new" ] && [ "$new" != null ] || fail "Evidence не доказывает замену task"
docker service ps --format '{{.ID}} {{.CurrentState}}' market_catalog-api | grep -E "^$new Running" >/dev/null || fail "Replacement task не running"
[ "$(docker service ls --filter name=market_catalog-api --format '{{.Replicas}}')" = 2/2 ] || fail "Catalog replicas не восстановлены"
jq -e '.items|length>0' < <(curl -fsS http://127.0.0.1:8080/catalog) >/dev/null || fail "Каталог недоступен"
echo "OK: reconciliation восстановил удалённую task"
