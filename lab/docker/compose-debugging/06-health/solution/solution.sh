#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
CID="$("${COMPOSE[@]}" ps -q api)"
for _ in $(seq 1 12); do
  STATUS="$(docker inspect -f '{{.State.Health.Status}}' "$CID")"
  [ "$STATUS" = unhealthy ] && break
  sleep 3
done
docker inspect "$CID" --format '{{json .State}}' | python3 -m json.tool > "$LAB/evidence/health-inspect.json"
sed -i 's#API_HEALTH_PATH: /healthz-broken#API_HEALTH_PATH: /health#' "$LAB/compose.yaml"
"${COMPOSE[@]}" up -d --force-recreate --wait api web
chown ubuntu:ubuntu "$LAB/compose.yaml" "$LAB/evidence/health-inspect.json"
