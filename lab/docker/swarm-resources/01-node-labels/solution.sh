#!/usr/bin/env bash
set -euo pipefail
manager_id=$(docker node inspect self --format '{{.ID}}')
docker node update --label-add swarm_resources=true "$manager_id" >/dev/null
