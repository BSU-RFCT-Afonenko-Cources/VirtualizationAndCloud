#!/usr/bin/env bash
set -euo pipefail
BASELINE=/home/ubuntu/swarm-basic/swarm-basic-task-before.txt
CURRENT=/home/ubuntu/swarm-basic/swarm-basic-task-current.txt
[ -s "$BASELINE" ] || { echo 'Task baseline is missing; reopen the step'; exit 1; }
docker service ps --filter desired-state=running --format '{{.ID}}' lab-api | sort > "$CURRENT"
[ "$(wc -l < "$CURRENT")" -eq 3 ] || { echo 'Service has not recovered to three desired tasks'; exit 1; }
if cmp --silent "$BASELINE" "$CURRENT"; then
  echo 'No replacement task was detected'
  exit 1
fi
running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
[ "$running" -eq 3 ] || { echo 'Replacement tasks are not all running'; exit 1; }
docker service ps --no-trunc --format '{{.CurrentState}} {{.Error}}' lab-api | grep -Eq 'Shutdown|Failed|Rejected|Complete' || { echo 'No completed or failed task is present in service history'; exit 1; }
curl --fail --silent --max-time 5 http://127.0.0.1:8080/ | jq -e '.status == "ok"' >/dev/null || { echo 'HTTP endpoint is unavailable'; exit 1; }
echo 'A failed task was replaced and service availability was restored.'
