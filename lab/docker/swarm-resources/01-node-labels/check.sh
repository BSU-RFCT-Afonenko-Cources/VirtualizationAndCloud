#!/usr/bin/env bash
set -euo pipefail
value=$(docker node inspect self --format '{{ index .Spec.Labels "swarm_resources" }}')
[ "$value" = true ] || { echo "label swarm_resources=true отсутствует" >&2; exit 1; }
echo "node label swarm_resources=true найден"
