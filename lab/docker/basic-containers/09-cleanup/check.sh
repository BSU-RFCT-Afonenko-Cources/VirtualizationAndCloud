#!/bin/bash
set -euo pipefail
if /usr/bin/docker container ls --all --format '{{.Names}}' | /usr/bin/grep -E '^lab-' >/dev/null; then exit 1; fi
if /usr/bin/docker network ls --format '{{.Name}}' | /usr/bin/grep -E '^lab-' >/dev/null; then exit 1; fi
if /usr/bin/docker image ls --format '{{.Repository}}' | /usr/bin/grep -E '^lab-' >/dev/null; then exit 1; fi
if [ -f /home/ubuntu/basic-containers/evidence/containers.json ]; then
  while IFS= read -r container_id; do
    name="$(/usr/bin/jq -r --arg id "$container_id" '.[] | select(.Id == $id) | .Name' /home/ubuntu/basic-containers/evidence/containers.json)"
    case "$name" in /lab-*) continue ;; esac
    /usr/bin/docker container inspect "$container_id" >/dev/null
  done < <(/usr/bin/jq -r '.[].Id' /home/ubuntu/basic-containers/evidence/containers.json)
fi
