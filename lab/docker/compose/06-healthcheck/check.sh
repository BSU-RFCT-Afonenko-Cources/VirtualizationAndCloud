#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/compose-lab
docker compose up -d --build
for service in db api web; do
  cid=$(docker compose ps -q "$service")
  test -n "$cid" || exit 1
  test "$(docker inspect "$cid" --format '{{if .Config.Healthcheck}}yes{{end}}')" = yes || { echo "Нет healthcheck у $service"; exit 1; }
  state=
  for _ in $(seq 1 45); do state=$(docker inspect "$cid" --format '{{.State.Health.Status}}'); test "$state" = healthy && break; test "$state" = unhealthy && { docker inspect "$cid" --format '{{json .State.Health.Log}}'; exit 1; }; sleep 1; done
  test "$state" = healthy || { echo "$service не стал healthy"; exit 1; }
done
echo "Все сервисы healthy"
