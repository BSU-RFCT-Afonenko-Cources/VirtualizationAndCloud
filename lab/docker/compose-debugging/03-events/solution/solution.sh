#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
CID="$("${COMPOSE[@]}" ps -q api)"
SINCE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
"${COMPOSE[@]}" restart api
sleep 2
UNTIL="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
docker events --since "$SINCE" --until "$UNTIL" --filter "container=$CID" --format '{{json .}}' > "$LAB/evidence/api-events.jsonl"
chown ubuntu:ubuntu "$LAB/evidence/api-events.jsonl"
