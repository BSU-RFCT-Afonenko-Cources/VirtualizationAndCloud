#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
for net in frontend backend data; do
  [ "$(docker network inspect --format '{{.Driver}}' "market_$net")" = overlay ] || fail "market_$net не overlay"
  [ "$(docker network inspect --format '{{.Scope}}' "market_$net")" = swarm ] || fail "market_$net не swarm scope"
done
has_net() { docker service inspect --format '{{range .Spec.TaskTemplate.Networks}}{{.Target}} {{end}}' "$1" | grep -qw "$(docker network inspect --format '{{.Id}}' "$2")"; }
has_net market_edge market_frontend && has_net market_edge market_backend || fail "Неверные сети edge"
has_net market_orders-api market_backend && has_net market_orders-api market_data || fail "Неверные сети orders-api"
has_net market_catalog-api market_backend || fail "catalog-api не в backend"
has_net market_db market_data && has_net market_worker market_data || fail "db/worker не в data"
for service in orders-api catalog-api db worker; do
  [ "$(docker service inspect --format '{{len .Endpoint.Spec.Ports}}' "market_$service")" = 0 ] || fail "market_$service публикует порт"
done
[ "$(docker service inspect --format '{{(index .Endpoint.Spec.Ports 0).PublishedPort}}' market_edge)" = 8080 ] || fail "Edge не публикует 8080"
echo "OK: overlay segmentation и публикация edge корректны"
