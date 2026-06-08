#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ] || fail "Swarm не active"
[ "$(docker stack services market --format '{{.Name}}' | wc -l)" -eq 5 ] || fail "Stack должен содержать 5 services"
for service in edge orders-api catalog-api db worker; do
  replicas=$(docker service ls --filter name="market_$service" --format '{{.Replicas}}')
  desired=${replicas#*/}; running=${replicas%/*}; [ "$running" = "$desired" ] && [ "$desired" -gt 0 ] || fail "market_$service не converged: $replicas"
  state=$(docker service inspect --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' "market_$service")
  [[ -z "$state" || "$state" = completed || "$state" = rollback_completed ]] || fail "market_$service имеет незавершённый update: $state"
done
[ "$(docker service inspect --format '{{.Spec.Mode.Replicated.Replicas}}' market_orders-api)" -ge 3 ] || fail "Недостаточно orders replicas"
[ "$(docker service inspect --format '{{.Spec.Mode.Replicated.Replicas}}' market_catalog-api)" -ge 2 ] || fail "Недостаточно catalog replicas"
docker secret inspect market_db_password >/dev/null || fail "DB secret отсутствует"
docker config inspect market_edge_routes >/dev/null || fail "Routes config отсутствует"
docker volume inspect market_db-data >/dev/null || fail "DB volume отсутствует"
jq -e '.status=="ok"' < <(curl -fsS http://127.0.0.1:8080/health) >/dev/null || fail "Edge health failed"
jq -e '.items|length>0' < <(curl -fsS http://127.0.0.1:8080/catalog) >/dev/null || fail "Catalog workflow failed"
created=$(curl -fsS -X POST -H 'Content-Type: application/json' -d '{"item":"acceptance-check","quantity":3}' http://127.0.0.1:8080/orders); id=$(jq -r '.id' <<<"$created")
jq -e --arg id "$id" '.id==$id and .item=="acceptance-check" and .quantity==3' < <(curl -fsS "http://127.0.0.1:8080/orders/$id") >/dev/null || fail "Order workflow failed"
echo "OK: итоговая приёмка stack market пройдена"
