#!/bin/bash
set -euo pipefail

name=$(/usr/bin/docker inspect --format '{{.Name}}' lab-registry 2>/dev/null || true)
[ "$name" = "/lab-registry" ] || { echo "Контейнер lab-registry не найден"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-registry)" = "true" ] || { echo "Registry не запущен"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' lab-registry)" = "unless-stopped" ] || { echo "Настройте restart policy unless-stopped"; exit 1; }
binding=$(/usr/bin/docker inspect --format '{{(index (index .NetworkSettings.Ports "5000/tcp") 0).HostPort}}' lab-registry)
[ "$binding" = "5000" ] || { echo "Порт registry должен быть опубликован как 5000:5000"; exit 1; }
/usr/bin/curl --fail --silent http://127.0.0.1:5000/v2/ >/dev/null || { echo "Registry HTTP API v2 недоступен"; exit 1; }
