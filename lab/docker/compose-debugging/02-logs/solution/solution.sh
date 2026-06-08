#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
curl --fail --silent -H 'X-Request-ID: lab-logs-02' http://127.0.0.1:8080/api/items >/dev/null
sleep 1
"${COMPOSE[@]}" logs --no-color web | tail -n 80 > "$LAB/evidence/web.log"
"${COMPOSE[@]}" logs --no-color api | tail -n 80 > "$LAB/evidence/api.log"
"${COMPOSE[@]}" logs --no-color db | tail -n 120 > "$LAB/evidence/db.log"
chown ubuntu:ubuntu "$LAB/evidence/web.log" "$LAB/evidence/api.log" "$LAB/evidence/db.log"
