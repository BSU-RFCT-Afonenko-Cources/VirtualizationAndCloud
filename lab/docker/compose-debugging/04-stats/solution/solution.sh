#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
for _ in $(seq 1 30); do curl --silent --max-time 3 'http://127.0.0.1:8080/api/load?seconds=0.2' >/dev/null & done
sleep 1
docker stats --no-stream --format '{{json .}}' $(docker compose -p web-api-db -f "$LAB/compose.yaml" ps -q) > "$LAB/evidence/stats.jsonl"
wait
chown ubuntu:ubuntu "$LAB/evidence/stats.jsonl"
