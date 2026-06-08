#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-resources/evidence/overcommit-pending.json
[ -f "$EVIDENCE" ]
jq -e '.service == "lab-overcommit" and .desired_state == "Running" and (.current_state | startswith("Pending")) and (.error | ascii_downcase | contains("insufficient resources"))' "$EVIDENCE" >/dev/null
read -r cpu memory < <(docker service inspect lab-overcommit --format '{{.Spec.TaskTemplate.Resources.Reservations.NanoCPUs}} {{.Spec.TaskTemplate.Resources.Reservations.MemoryBytes}}')
[ "$cpu" -eq 50000000 ]
[ "$memory" -eq 33554432 ]
timeout 45 bash -c 'until [ "$(docker service ps lab-overcommit --filter desired-state=running --format "{{.CurrentState}}" | awk '"'"'$1 == "Running" {n++} END {print n+0}'"'"')" -eq 1 ]; do sleep 1; done'
echo "pending evidence и восстановление scheduling проверены"
