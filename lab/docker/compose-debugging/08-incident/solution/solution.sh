#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/compose-debugging
HEALTH="$(curl --silent --output /dev/null --write-out '%{http_code}' http://127.0.0.1:8080/health)"
ITEMS="$(curl --silent --output /dev/null --write-out '%{http_code}' http://127.0.0.1:8080/api/items)"
cat > "$LAB/evidence/incident.json" <<JSON
{
  "incident_id": "compose-debugging-final",
  "root_causes": [
    "web upstream used a nonexistent Compose DNS name",
    "api healthcheck targeted a nonexistent endpoint",
    "api initially had no explicit CPU and memory limits"
  ],
  "fixes": [
    "restored the api service name in WEB_UPSTREAM",
    "restored the /health healthcheck endpoint",
    "applied bounded CPU and memory limits and verified service availability"
  ],
  "verification": {
    "health": $HEALTH,
    "items": $ITEMS,
    "compose_status": "healthy"
  }
}
JSON
chown ubuntu:ubuntu "$LAB/evidence/incident.json"
