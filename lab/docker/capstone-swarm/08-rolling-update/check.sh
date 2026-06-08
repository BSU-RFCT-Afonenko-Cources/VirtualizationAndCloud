#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
image=$(docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' market_orders-api)
[[ "$image" == localhost:5000/market-orders:2.0@sha256:* || "$image" = localhost:5000/market-orders:2.0 ]] || fail "orders-api не на версии 2.0"
[ "$(docker service inspect --format '{{.UpdateStatus.State}}' market_orders-api)" = completed ] || fail "Rolling update не завершён"
[ "$(docker service inspect --format '{{.Spec.UpdateConfig.Parallelism}}' market_orders-api)" = 1 ] || fail "Parallelism должен быть 1"
[ "$(docker service inspect --format '{{.Spec.UpdateConfig.Order}}' market_orders-api)" = start-first ] || fail "Update order должен быть start-first"
shutdown=$(docker service ps --no-trunc --filter desired-state=shutdown --format '{{.ID}}' market_orders-api | wc -l)
[ "$shutdown" -ge 1 ] || fail "Нет истории заменённых tasks"
jq -e '.version=="2.0"' < <(curl -fsS http://127.0.0.1:8080/orders/version) >/dev/null || fail "Endpoint не сообщает 2.0"
grep -q 'market-orders:2.0' /home/ubuntu/capstone-swarm/market-stack.yml || fail "Stack-файл не синхронизирован с 2.0"
echo "OK: rolling update до 2.0 завершён"
