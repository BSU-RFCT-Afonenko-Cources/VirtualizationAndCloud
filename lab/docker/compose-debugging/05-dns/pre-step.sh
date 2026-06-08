#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
sed -i -E 's/WEB_UPSTREAM: (api|missing-api|apix):8080/WEB_UPSTREAM: missing-api:8080/' "$LAB/compose.yaml"
rm -f "$LAB/evidence/dns-error.txt"
docker compose -p web-api-db -f "$LAB/compose.yaml" up -d --force-recreate --no-deps web || true
chown ubuntu:ubuntu "$LAB/compose.yaml"
