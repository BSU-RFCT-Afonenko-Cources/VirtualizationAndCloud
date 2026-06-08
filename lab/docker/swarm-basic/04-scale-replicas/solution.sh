#!/usr/bin/env bash
set -euo pipefail
docker service scale lab-api=3
for attempt in $(seq 1 45); do
  running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
  [ "$running" -eq 3 ] && exit 0
  sleep 1
done
docker service ps lab-api
exit 1
