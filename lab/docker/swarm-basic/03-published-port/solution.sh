#!/usr/bin/env bash
set -euo pipefail
if ! docker service inspect --format '{{range .Endpoint.Ports}}{{if eq .PublishedPort 8080}}yes{{end}}{{end}}' lab-api | grep -q yes; then
  docker service update --publish-add published=8080,target=8000,protocol=tcp,mode=ingress lab-api
fi
for attempt in $(seq 1 30); do
  curl --fail --silent --max-time 2 http://127.0.0.1:8080/ >/dev/null && exit 0
  sleep 1
done
exit 1
