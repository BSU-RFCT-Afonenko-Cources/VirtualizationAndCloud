#!/usr/bin/env bash
set -euo pipefail

PREVIOUS_FILE=/var/lib/image-lab/previous-container-id
[[ -f "$PREVIOUS_FILE" ]] || { echo "Не сохранён ID исходного контейнера"; exit 1; }
PREVIOUS=$(cat "$PREVIOUS_FILE")
CURRENT=$(docker container inspect --format '{{.Id}}' image-lab-api)
[[ "$CURRENT" != "$PREVIOUS" ]] || { echo "Контейнер не был пересоздан"; exit 1; }
[[ "$(docker inspect --format '{{.Config.Image}}' image-lab-api)" == image-lab:v2 ]] || { echo "Контейнер создан не из image-lab:v2"; exit 1; }
[[ "$(docker inspect --format '{{.State.Running}}' image-lab-api)" == true ]] || { echo "Новый контейнер не запущен"; exit 1; }
[[ "$(docker inspect --format '{{(index (index .HostConfig.PortBindings "8080/tcp") 0).HostPort}}' image-lab-api)" == 18080 ]] || { echo "Порт 18080 не опубликован"; exit 1; }
for _ in $(seq 1 20); do
  [[ "$(docker inspect --format '{{.State.Health.Status}}' image-lab-api)" == healthy ]] && break
  sleep 1
done
[[ "$(docker inspect --format '{{.State.Health.Status}}' image-lab-api)" == healthy ]] || { echo "Новый контейнер не healthy"; exit 1; }
curl --fail --silent --max-time 5 http://127.0.0.1:18080/health | python3 -c 'import json,sys; assert json.load(sys.stdin)["status"] == "ok"'
curl --fail --silent --max-time 5 http://127.0.0.1:18080/version | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"] == "2.0.0"'
