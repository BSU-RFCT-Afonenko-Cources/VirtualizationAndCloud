#!/usr/bin/env bash
set -euo pipefail
read -r cpu memory < <(docker service inspect lab-worker --format '{{.Spec.TaskTemplate.Resources.Reservations.NanoCPUs}} {{.Spec.TaskTemplate.Resources.Reservations.MemoryBytes}}')
[ "$cpu" -eq 250000000 ] || { echo "reservation CPU должна быть 0.25" >&2; exit 1; }
[ "$memory" -eq 134217728 ] || { echo "reservation memory должна быть 128 MiB" >&2; exit 1; }
timeout 45 bash -c 'until [ "$(docker service ps lab-worker --filter desired-state=running --format "{{.CurrentState}}" | awk '"'"'$1 == "Running" {n++} END {print n+0}'"'"')" -eq 1 ]; do sleep 1; done'
timeout 25 bash -c 'until docker service logs lab-worker 2>&1 | grep -q batch_processed; do sleep 1; done'
echo "reservations и работа worker проверены"
