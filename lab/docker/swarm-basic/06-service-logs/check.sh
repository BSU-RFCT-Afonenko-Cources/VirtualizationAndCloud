#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-basic/service-logs.txt
[ -f "$EVIDENCE" ] || { echo 'service-logs.txt is missing'; exit 1; }
[ -s "$EVIDENCE" ] || { echo 'service-logs.txt is empty'; exit 1; }
[ "$(grep -c 'swarm-api request' "$EVIDENCE" || true)" -ge 3 ] || { echo 'Evidence must contain at least three API request records'; exit 1; }
grep -Eq 'lab-api(\.[0-9]+)?\.' "$EVIDENCE" || { echo 'Task context for lab-api is missing from evidence'; exit 1; }
actual="$(docker service logs --raw --since 30m lab-api 2>&1 | grep -c 'swarm-api request' || true)"
[ "$actual" -ge 3 ] || { echo 'Current service logs do not confirm three requests'; exit 1; }
echo 'Service log evidence contains request records from lab-api tasks.'
