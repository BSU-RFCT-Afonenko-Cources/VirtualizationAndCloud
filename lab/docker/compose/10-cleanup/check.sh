#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
if docker ps -aq --filter label=com.docker.compose.project=compose-lab | grep -q .; then echo "Контейнеры проекта не удалены"; exit 1; fi
if docker network ls -q --filter label=com.docker.compose.project=compose-lab | grep -q .; then echo "Сети проекта не удалены"; exit 1; fi
volume_id=$(docker volume ls -q --filter label=com.docker.compose.project=compose-lab --filter label=com.docker.compose.volume=db-data)
test -n "$volume_id" || { echo "Volume db-data был удалён"; exit 1; }
mountpoint=$(docker volume inspect "$volume_id" --format '{{.Mountpoint}}')
test -d "$mountpoint" && find "$mountpoint" -mindepth 1 -print -quit | grep -q . || { echo "Volume не содержит данных Redis"; exit 1; }
echo "Контейнеры и сети удалены, persistent volume сохранён"
