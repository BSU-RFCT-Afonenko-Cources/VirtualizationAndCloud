#!/usr/bin/env bash
set -euo pipefail

TEST=$(docker image inspect --format '{{json .Config.Healthcheck.Test}}' image-lab:latest)
[[ "$TEST" == *'/health'* ]] || { echo "Healthcheck образа не проверяет /health"; exit 1; }
for _ in $(seq 1 20); do
  STATUS=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' image-lab-api)
  [[ "$STATUS" == healthy ]] && exit 0
  [[ "$STATUS" == unhealthy ]] && { docker inspect --format '{{json .State.Health.Log}}' image-lab-api; exit 1; }
  sleep 1
done
echo "Контейнер не перешёл в healthy"
exit 1
