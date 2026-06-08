#!/usr/bin/env bash
set -euo pipefail
docker service rollback --detach=false orders-api >/dev/null
