#!/usr/bin/env bash
set -euo pipefail
docker service scale orders-api=5 >/dev/null
docker service update --detach=false orders-api >/dev/null
