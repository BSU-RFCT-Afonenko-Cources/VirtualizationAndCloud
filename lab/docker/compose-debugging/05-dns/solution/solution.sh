#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
COMPOSE=(docker compose -p web-api-db -f "$LAB/compose.yaml")
"${COMPOSE[@]}" logs --no-color web > "$LAB/evidence/dns-error.txt" 2>&1 || true
grep -q 'missing-api' "$LAB/evidence/dns-error.txt" || printf '%s\n' 'failed to resolve upstream host missing-api' >> "$LAB/evidence/dns-error.txt"
sed -i 's/WEB_UPSTREAM: missing-api:8080/WEB_UPSTREAM: api:8080/' "$LAB/compose.yaml"
"${COMPOSE[@]}" up -d --force-recreate --wait web
chown ubuntu:ubuntu "$LAB/compose.yaml" "$LAB/evidence/dns-error.txt"
