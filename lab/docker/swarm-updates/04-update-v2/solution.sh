#!/usr/bin/env bash
set -euo pipefail
docker service update --image orders-api:v2 --detach=false orders-api >/dev/null
