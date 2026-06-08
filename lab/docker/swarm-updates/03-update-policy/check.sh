#!/usr/bin/env bash
set -euo pipefail
fail() { echo "Ошибка: $*" >&2; exit 1; }
json=$(docker service inspect orders-api 2>/dev/null) || fail "service orders-api не найден"
jq -e '
  .[0].Spec.UpdateConfig.Parallelism == 1 and
  .[0].Spec.UpdateConfig.Delay == 5000000000 and
  .[0].Spec.UpdateConfig.Monitor == 20000000000 and
  .[0].Spec.UpdateConfig.FailureAction == "pause" and
  .[0].Spec.UpdateConfig.MaxFailureRatio == 0.25 and
  .[0].Spec.UpdateConfig.Order == "start-first" and
  .[0].Spec.RollbackConfig.Parallelism == 2 and
  .[0].Spec.RollbackConfig.Delay == 0 and
  .[0].Spec.RollbackConfig.FailureAction == "pause" and
  .[0].Spec.RollbackConfig.Order == "stop-first"
' <<<"$json" >/dev/null || fail "UpdateConfig или RollbackConfig не соответствует заданию"
[ "$(jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Image' <<<"$json" | sed 's/@.*//')" = "orders-api:v1" ] || fail "образ baseline был изменён"
[ "$(jq -r '.[0].Spec.Mode.Replicated.Replicas' <<<"$json")" = "5" ] || fail "число реплик было изменено"
echo "UpdateConfig и RollbackConfig настроены"
