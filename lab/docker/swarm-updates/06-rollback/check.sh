#!/usr/bin/env bash
set -euo pipefail
fail() { echo "Ошибка: $*" >&2; exit 1; }
json=$(docker service inspect orders-api 2>/dev/null) || fail "service orders-api не найден"
[ "$(jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Image' <<<"$json" | sed 's/@.*//')" = "orders-api:v2" ] || fail "rollback не восстановил orders-api:v2"
state=$(jq -r '.[0].UpdateStatus.State // empty' <<<"$json")
[ "$state" = "rollback_completed" ] || fail "состояние rollback: $state, ожидается rollback_completed"
running=$(docker service ps --filter desired-state=running --format '{{.Image}} {{.CurrentState}}' orders-api | awk '$1 ~ /^orders-api:v2(@|$)/ && $2 == "Running" {count++} END {print count+0}')
[ "$running" = "5" ] || fail "после rollback работают $running из 5 tasks v2"
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | jq -r '.version')" = "v2" ] || fail "endpoint не восстановлен на v2"
echo "Rollback завершён: orders-api:v2, 5/5 replicas"
