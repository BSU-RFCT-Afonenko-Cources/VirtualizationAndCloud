#!/usr/bin/env bash
set -euo pipefail
port="$(docker service inspect --format '{{range .Endpoint.Ports}}{{if and (eq .PublishedPort 8080) (eq .TargetPort 8000) (eq .PublishMode "ingress")}}{{.PublishedPort}}{{end}}{{end}}' lab-api 2>/dev/null)"
[ "$port" = 8080 ] || { echo 'Expected ingress mapping 8080 -> 8000'; exit 1; }
response="$(curl --fail --silent --max-time 5 http://127.0.0.1:8080/)" || { echo 'HTTP endpoint is unavailable'; exit 1; }
printf '%s' "$response" | jq -e '.service == "swarm-api" and .status == "ok"' >/dev/null || { echo 'Unexpected API response'; exit 1; }
echo 'Ingress port 8080 routes requests to swarm-api:8000.'
