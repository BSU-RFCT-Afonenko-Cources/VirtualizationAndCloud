#!/usr/bin/env bash
set -euo pipefail
docker service update \
  --update-parallelism 1 \
  --update-delay 5s \
  --update-monitor 20s \
  --update-failure-action pause \
  --update-max-failure-ratio 0.25 \
  --update-order start-first \
  --rollback-parallelism 2 \
  --rollback-delay 0s \
  --rollback-monitor 20s \
  --rollback-failure-action pause \
  --rollback-order stop-first \
  orders-api >/dev/null
