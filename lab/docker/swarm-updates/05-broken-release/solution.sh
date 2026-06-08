#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-updates/evidence/broken-release.json

docker service update --image orders-api:bad orders-api >/dev/null
for _ in $(seq 1 90); do
  state=$(docker service inspect --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' orders-api)
  if [ "$state" = "paused" ]; then break; fi
  sleep 1
done
state=$(docker service inspect --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' orders-api)
[ "$state" = "paused" ] || { echo "Обновление не перешло в paused" >&2; exit 1; }

docker service ps --no-trunc --format '{{json .}}' orders-api | jq -s \
  --arg state "$state" \
  '{service:"orders-api", attempted_image:"orders-api:bad", update_state:$state, message:"healthcheck stopped the rollout", tasks:.}' \
  > "$EVIDENCE"
chown ubuntu:ubuntu "$EVIDENCE"
