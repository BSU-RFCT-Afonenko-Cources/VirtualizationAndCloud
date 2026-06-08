#!/usr/bin/env bash
set -euo pipefail

fail() { echo "Ошибка: $*" >&2; exit 1; }
service_json=$(docker service inspect orders-api 2>/dev/null) || fail "service orders-api не найден"
[ "$(jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Image' <<<"$service_json" | sed 's/@.*//')" = "orders-api:v1" ] || fail "ожидается образ orders-api:v1"
[ "$(jq -r '.[0].Spec.Mode.Replicated.Replicas' <<<"$service_json")" = "3" ] || fail "ожидаются три desired replicas"
[ "$(jq -r '.[0].Endpoint.Ports[]? | select(.PublishedPort == 18080 and .TargetPort == 8080) | .PublishedPort' <<<"$service_json")" = "18080" ] || fail "порт 18080 не опубликован на target 8080"
[ "$(jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Healthcheck.Test[0] // empty' <<<"$service_json")" = "CMD-SHELL" ] || fail "healthcheck не настроен"
running=$(docker service ps --filter desired-state=running --format '{{.CurrentState}}' orders-api | awk '$1 == "Running" {count++} END {print count+0}')
[ "$running" = "3" ] || fail "выполняются $running из 3 реплик"
version=$(curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | jq -r '.version') || fail "endpoint /version недоступен"
[ "$version" = "v1" ] || fail "endpoint сообщает версию $version вместо v1"
echo "Baseline готов: orders-api:v1, 3/3 replicas, HTTP доступен"
