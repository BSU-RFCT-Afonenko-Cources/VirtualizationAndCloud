#!/usr/bin/env bash
set -euo pipefail

CONFIG_USER=$(docker image inspect --format '{{.Config.User}}' image-lab:latest)
[[ -n "$CONFIG_USER" && "$CONFIG_USER" != root && "$CONFIG_USER" != 0 ]] || { echo "В image config не задан непривилегированный USER"; exit 1; }
UID_IN_CONTAINER=$(docker exec image-lab-api id -u)
USER_IN_CONTAINER=$(docker exec image-lab-api id -un)
[[ "$UID_IN_CONTAINER" != 0 && "$USER_IN_CONTAINER" == app ]] || { echo "API работает не от пользователя app"; exit 1; }
curl --fail --silent --max-time 5 --retry 10 --retry-connrefused --retry-delay 1 http://127.0.0.1:18080/health >/dev/null
