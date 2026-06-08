#!/bin/bash
set -euo pipefail
IMAGE=security-api:lab
CONTAINER=security-api
docker image inspect "$IMAGE" >/dev/null 2>&1 || { echo "Образ $IMAGE не найден"; exit 1; }
[ "$(docker image inspect -f '{{.Config.User}}' "$IMAGE")" = "10001:10001" ] || { echo "В образе не задан USER 10001:10001"; exit 1; }
[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = true ] || { echo "Контейнер $CONTAINER не запущен"; exit 1; }
[ "$(docker exec "$CONTAINER" python -c 'import os; print(os.geteuid())')" = 10001 ] || { echo "Effective UID процесса должен быть 10001"; exit 1; }
BINDING=$(docker inspect -f '{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostIp}}:{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' "$CONTAINER")
[ "$BINDING" = "127.0.0.1:18080" ] || { echo "Ожидается публикация 127.0.0.1:18080"; exit 1; }
python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:18080/health', timeout=3)" >/dev/null
echo "API работает с effective UID 10001"
