#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
docker stack config -c /home/ubuntu/capstone-swarm/market-stack.yml >/dev/null || fail "Stack-файл невалиден"
for service in edge orders-api catalog-api db worker; do
  docker service inspect "market_$service" >/dev/null 2>&1 || fail "Нет сервиса market_$service"
  [ "$(docker service inspect --format '{{index .Spec.Labels "com.docker.stack.namespace"}}' "market_$service")" = market ] || fail "У market_$service нет stack label"
done
echo "OK: stack market содержит пять сервисов"
