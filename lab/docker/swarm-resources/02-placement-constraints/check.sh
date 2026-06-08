#!/usr/bin/env bash
set -euo pipefail
constraints=$(docker service inspect lab-api --format '{{json .Spec.TaskTemplate.Placement.Constraints}}')
printf '%s' "$constraints" | jq -e 'index("node.labels.swarm_resources == true") != null' >/dev/null
timeout 45 bash -c 'until [ "$(docker service ps lab-api --filter desired-state=running --format "{{.CurrentState}}" | awk '"'"'$1 == "Running" {n++} END {print n+0}'"'"')" -eq 1 ]; do sleep 1; done'
node=$(docker service ps lab-api --filter desired-state=running --format '{{.Node}}' | head -n1)
[ "$(docker node inspect "$node" --format '{{ index .Spec.Labels "swarm_resources" }}')" = true ]
response=$(curl --fail --silent --retry 10 --retry-delay 1 http://127.0.0.1:18080/health)
printf '%s' "$response" | jq -e '.service == "swarm-resources-api" and .status == "ok"' >/dev/null
echo "constraint, running task и API endpoint проверены"
