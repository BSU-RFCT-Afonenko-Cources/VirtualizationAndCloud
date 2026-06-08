#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
fail() { echo "ОШИБКА: $*" >&2; exit 1; }
docker secret inspect market_db_password >/dev/null || fail "Нет secret market_db_password"
for config in market_edge_routes market_api_config; do docker config inspect "$config" >/dev/null || fail "Нет config $config"; done
secret_id=$(docker secret inspect --format '{{.ID}}' market_db_password)
for service in market_orders-api market_db market_worker; do
  docker service inspect --format '{{range .Spec.TaskTemplate.ContainerSpec.Secrets}}{{.SecretID}} {{end}}' "$service" | grep -qw "$secret_id" || fail "$service не использует DB secret"
done
routes_id=$(docker config inspect --format '{{.ID}}' market_edge_routes)
docker service inspect --format '{{range .Spec.TaskTemplate.ContainerSpec.Configs}}{{.ConfigID}} {{end}}' market_edge | grep -qw "$routes_id" || fail "edge не использует routes config"
! grep -Eqi 'POSTGRES_PASSWORD:[[:space:]]*[^/]|swarm-capstone-db-2026' /home/ubuntu/capstone-swarm/market-stack.yml || fail "Пароль открыт в stack-файле"
for service in market_orders-api market_db market_worker; do
  ! docker service inspect --format '{{json .Spec.TaskTemplate.ContainerSpec.Env}}' "$service" | grep -q 'swarm-capstone-db-2026' || fail "Пароль открыт в environment $service"
done
container=$(docker ps --filter label=com.docker.swarm.service.name=market_orders-api --format '{{.ID}}' | head -1)
[ -n "$container" ] || fail "Нет running orders-api task"
docker exec "$container" test -s /run/secrets/db_password || fail "Secret не смонтирован в task"
echo "OK: secrets/configs подключены без plaintext password"
