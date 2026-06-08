#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
sed -i -E 's#API_HEALTH_PATH: /health(z-broken)?#API_HEALTH_PATH: /healthz-broken#' "$LAB/compose.yaml"
rm -f "$LAB/evidence/health-inspect.json"
docker compose -p web-api-db -f "$LAB/compose.yaml" up -d --force-recreate --no-deps api
chown ubuntu:ubuntu "$LAB/compose.yaml"
