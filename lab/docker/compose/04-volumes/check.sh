#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
docker compose up -d --build
volume_id=$(docker volume ls -q --filter label=com.docker.compose.project=compose-lab --filter label=com.docker.compose.volume=db-data)
test -n "$volume_id" || { echo "Named volume db-data не найден"; exit 1; }
cid=$(docker compose ps -q db)
mount=$(docker inspect "$cid" --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}} {{.Type}}{{end}}{{end}}')
test "$mount" = "$volume_id volume" || { echo "Volume не смонтирован в /data"; exit 1; }
until docker compose exec -T db redis-cli ping | grep -qx PONG; do sleep 1; done
before=$(docker compose exec -T db redis-cli INCR lab:persistence-check | tr -d '\r')
docker compose up -d --force-recreate db
until docker compose exec -T db redis-cli ping | grep -qx PONG; do sleep 1; done
after=$(docker compose exec -T db redis-cli GET lab:persistence-check | tr -d '\r')
test "$after" = "$before" || { echo "Данные не сохранились после пересоздания db"; exit 1; }
echo "Named volume сохраняет данные"
