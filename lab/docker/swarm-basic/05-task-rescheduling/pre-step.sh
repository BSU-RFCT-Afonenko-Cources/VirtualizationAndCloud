#!/usr/bin/env bash
set -euo pipefail
BASELINE=/var/lib/swarm-basic-task-before.txt
docker service ps --filter desired-state=running --format '{{.ID}}' lab-api | sort > "$BASELINE"
[ "$(wc -l < "$BASELINE")" -eq 3 ] || { echo 'The step requires three running baseline tasks'; exit 1; }
