#!/usr/bin/env bash
set -euo pipefail
[ "$(docker service inspect --format '{{.Spec.Mode.Replicated.Replicas}}' lab-api 2>/dev/null)" = 3 ] || { echo 'Desired replicas must equal 3'; exit 1; }
running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
[ "$running" -eq 3 ] || { echo "Expected 3 running tasks, found $running"; docker service ps lab-api; exit 1; }
curl --fail --silent --max-time 5 http://127.0.0.1:8080/ | jq -e '.service == "swarm-api"' >/dev/null || { echo 'HTTP endpoint is unavailable'; exit 1; }
echo 'Service converged to 3/3 running replicas.'
