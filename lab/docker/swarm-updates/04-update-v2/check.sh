#!/usr/bin/env bash
set -euo pipefail
fail() { echo "Ошибка: $*" >&2; exit 1; }
image=$(docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' orders-api 2>/dev/null | sed 's/@.*//') || fail "service orders-api не найден"
[ "$image" = "orders-api:v2" ] || fail "service использует $image вместо orders-api:v2"
running=$(docker service ps --filter desired-state=running --format '{{.Image}} {{.CurrentState}}' orders-api | awk '$1 ~ /^orders-api:v2(@|$)/ && $2 == "Running" {count++} END {print count+0}')
[ "$running" = "5" ] || fail "работают $running из 5 tasks версии v2"
docker service ps --no-trunc --format '{{.Image}} {{.DesiredState}}' orders-api | awk '$1 ~ /^orders-api:v1(@|$)/ && $2 == "Shutdown" {found=1} END {exit !found}' || fail "в истории нет остановленных tasks версии v1"
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | jq -r '.version')" = "v2" ] || fail "smoke-test не получил v2"
echo "Rolling update завершён: v2, 5/5 replicas, история v1 сохранена"
