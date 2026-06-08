#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
evidence=/home/ubuntu/capstone-swarm/evidence/rollback.json
jq -e '.bad_image|endswith("market-orders:bad")' "$evidence" >/dev/null || fail "Evidence не содержит bad image"
failed=$(jq -r '.failed_task' "$evidence"); [ -n "$failed" ] && [ "$failed" != null ] || fail "Evidence не содержит failed task"
docker service ps --no-trunc --format '{{.ID}} {{.CurrentState}}' market_orders-api | grep -E "^$failed .*Failed" >/dev/null || fail "Failed task не найден в истории"
image=$(docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' market_orders-api); [[ "$image" == localhost:5000/market-orders:2.0* ]] || fail "Service не восстановлен на 2.0"
[ "$(docker service inspect --format '{{.UpdateStatus.State}}' market_orders-api)" = rollback_completed ] || fail "Rollback не завершён"
jq -e '.version=="2.0"' < <(curl -fsS http://127.0.0.1:8080/orders/version) >/dev/null || fail "Orders endpoint не восстановлен"
echo "OK: bad release зафиксирован и rollback завершён"
