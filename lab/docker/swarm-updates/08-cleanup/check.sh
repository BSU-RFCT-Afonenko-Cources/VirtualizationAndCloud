#!/usr/bin/env bash
set -euo pipefail
fail() { echo "Ошибка: $*" >&2; exit 1; }
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "active" ] || fail "узел больше не состоит в активном Swarm"
if docker service inspect orders-api >/dev/null 2>&1; then fail "service orders-api всё ещё существует"; fi
for image in orders-api:v1 orders-api:v2 orders-api:bad; do
  if docker image inspect "$image" >/dev/null 2>&1; then fail "образ $image не удалён"; fi
done
containers=$(docker ps -aq --filter 'label=com.docker.swarm.service.name=orders-api')
[ -z "$containers" ] || fail "остались контейнеры tasks сервиса orders-api"
if curl --silent --max-time 2 http://127.0.0.1:18080/version >/dev/null 2>&1; then fail "published endpoint 18080 всё ещё отвечает"; fi
echo "Нагрузка удалена; Swarm сохранён активным"
