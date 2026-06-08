#!/usr/bin/env bash
set -euo pipefail
fail() { echo "Ошибка: $*" >&2; exit 1; }
desired=$(docker service inspect --format '{{.Spec.Mode.Replicated.Replicas}}' orders-api 2>/dev/null) || fail "service orders-api не найден"
[ "$desired" = "5" ] || fail "desired replicas: $desired, ожидается 5"
running=$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' orders-api | awk '$1 == "Running" {count++} END {print count+0}')
[ "$running" = "5" ] || fail "running replicas: $running, ожидается 5"
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | jq -r '.version')" = "v1" ] || fail "API не отвечает версией v1"
echo "Scaling завершён: 5/5 replicas, API доступен"
