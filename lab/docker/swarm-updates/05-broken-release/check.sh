#!/usr/bin/env bash
set -euo pipefail
EVIDENCE=/home/ubuntu/swarm-updates/evidence/broken-release.json
fail() { echo "Ошибка: $*" >&2; exit 1; }
json=$(docker service inspect orders-api 2>/dev/null) || fail "service orders-api не найден"
[ "$(jq -r '.[0].UpdateStatus.State // empty' <<<"$json")" = "paused" ] || fail "rolling update не находится в состоянии paused"
[ "$(jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Image' <<<"$json" | sed 's/@.*//')" = "orders-api:bad" ] || fail "не зафиксирована попытка обновления на orders-api:bad"
bad_failure=0
while read -r task_id; do
  [ -n "$task_id" ] || continue
  task=$(docker inspect "$task_id")
  task_image=$(jq -r '.[0].Spec.ContainerSpec.Image' <<<"$task" | sed 's/@.*//')
  task_state=$(jq -r '.[0].Status.State' <<<"$task")
  if [ "$task_image" = "orders-api:bad" ] && [[ "$task_state" =~ ^(failed|shutdown|rejected)$ ]]; then
    bad_failure=1
  fi
done < <(docker service ps -q --no-trunc orders-api)
[ "$bad_failure" = "1" ] || fail "в истории нет неуспешной task образа bad"
[ -f "$EVIDENCE" ] || fail "отсутствует $EVIDENCE"
jq -e '
  .service == "orders-api" and
  .attempted_image == "orders-api:bad" and
  .update_state == "paused" and
  (.message | type == "string" and length > 0) and
  (.tasks | type == "array" and length > 0) and
  any(.tasks[]; (.Image // "") | startswith("orders-api:bad"))
' "$EVIDENCE" >/dev/null || fail "broken-release.json не соответствует схеме или фактическому сценарию"
echo "Плохой релиз остановлен; failed/unhealthy evidence сохранено"
