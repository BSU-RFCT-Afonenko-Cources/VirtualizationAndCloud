#!/usr/bin/env bash
set -euo pipefail

PROJECT=/home/ubuntu/image-lab
[[ -f "$PROJECT/Dockerfile" ]] || { echo "Отсутствует Dockerfile"; exit 1; }
docker image inspect image-lab:build >/dev/null
docker container inspect image-lab-api >/dev/null
[[ "$(docker inspect --format '{{.State.Running}}' image-lab-api)" == true ]] || { echo "Контейнер image-lab-api не запущен"; exit 1; }
PORTS=$(docker inspect --format '{{json .HostConfig.PortBindings}}' image-lab-api)
[[ "$PORTS" == *'18080'* ]] || { echo "Порт 18080 не опубликован"; exit 1; }
curl --fail --silent --max-time 5 --retry 10 --retry-connrefused --retry-delay 1 http://127.0.0.1:18080/health | python3 -c 'import json,sys; assert json.load(sys.stdin)["status"] == "ok"'
curl --fail --silent --max-time 5 --retry 10 --retry-connrefused --retry-delay 1 http://127.0.0.1:18080/version | python3 -c 'import json,sys; assert "version" in json.load(sys.stdin)'
