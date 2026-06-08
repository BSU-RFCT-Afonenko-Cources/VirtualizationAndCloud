#!/usr/bin/env bash
set -euo pipefail
docker service inspect lab-api >/dev/null 2>&1 || { echo 'Service lab-api does not exist'; exit 1; }
[ "$(docker service inspect --format '{{.Spec.Mode.Replicated.Replicas}}' lab-api)" = 1 ] || { echo 'Desired replicas must equal 1'; exit 1; }
[ "$(docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' lab-api | cut -d@ -f1)" = swarm-api:lab ] || { echo 'Unexpected service image'; exit 1; }
[ "$(docker service inspect --format '{{len .Endpoint.Ports}}' lab-api)" = 0 ] || { echo 'Do not publish a port yet'; exit 1; }
running="$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' lab-api | awk '$1 == "Running" {count++} END {print count+0}')"
[ "$running" -eq 1 ] || { echo 'Exactly one task must be running'; docker service ps lab-api; exit 1; }
echo 'Service lab-api has desired state 1/1 and one running task.'
