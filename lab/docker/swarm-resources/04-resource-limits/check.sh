#!/usr/bin/env bash
set -euo pipefail
inspect=$(docker service inspect lab-worker --format '{{json .Spec.TaskTemplate.Resources}}')
printf '%s' "$inspect" | jq -e '.Reservations.NanoCPUs == 250000000 and .Reservations.MemoryBytes == 134217728 and .Limits.NanoCPUs == 500000000 and .Limits.MemoryBytes == 268435456' >/dev/null
constraints=$(docker service inspect lab-worker --format '{{json .Spec.TaskTemplate.Placement.Constraints}}')
printf '%s' "$constraints" | jq -e 'index("node.labels.swarm_resources == true") != null' >/dev/null
[ "$(docker service inspect lab-worker --format '{{.Spec.Mode.Replicated.Replicas}}')" -eq 1 ]
timeout 45 bash -c 'until [ "$(docker service ps lab-worker --filter desired-state=running --format "{{.CurrentState}}" | awk '"'"'$1 == "Running" {n++} END {print n+0}'"'"')" -eq 1 ]; do sleep 1; done'
echo "limits, reservations и running state проверены"
