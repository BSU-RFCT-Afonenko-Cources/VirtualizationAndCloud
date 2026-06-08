#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
constraints=$(docker service inspect --format '{{json .Spec.TaskTemplate.Placement.Constraints}}' market_worker)
jq -e 'map(gsub("[[:space:]]";"")) | index("node.role==manager")' <<<"$constraints" >/dev/null || fail "Worker constraint отсутствует"
for service in market_worker market_orders-api market_catalog-api; do
  spec=$(docker service inspect --format '{{json .Spec.TaskTemplate.Resources}}' "$service")
  jq -e '.Reservations.NanoCPUs>0 and .Reservations.MemoryBytes>0 and .Limits.NanoCPUs>0 and .Limits.MemoryBytes>0 and .Limits.NanoCPUs>=.Reservations.NanoCPUs and .Limits.MemoryBytes>=.Reservations.MemoryBytes' <<<"$spec" >/dev/null || fail "Некорректные resources у $service"
done
docker stack config -c /home/ubuntu/capstone-swarm/market-stack.yml | grep -q 'node.role == manager' || fail "Policy не сохранена в stack-файле"
echo "OK: placement и resource policy заданы"
