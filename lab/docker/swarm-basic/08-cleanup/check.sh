#!/usr/bin/env bash
set -euo pipefail
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ]; then
  services="$(docker service ls --format '{{.Name}}' | awk '/^lab-/')"
  [ -z "$services" ] || { echo 'Lab services still exist:'; printf '%s\n' "$services"; exit 1; }
  containers="$(docker ps --all --filter label=com.docker.swarm.service.name=lab-api --format '{{.ID}}')"
  [ -z "$containers" ] || { echo 'Task containers for lab-api still exist'; exit 1; }
fi
[ -s /home/ubuntu/swarm-basic/service-logs.txt ] || { echo 'Service log evidence must be retained'; exit 1; }
[ -s /home/ubuntu/swarm-basic/lab-api-inspect.json ] || { echo 'Inspect evidence must be retained'; exit 1; }
echo 'No lab-* services remain; evidence is retained.'
