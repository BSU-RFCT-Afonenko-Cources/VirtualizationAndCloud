#!/usr/bin/env bash
set -euo pipefail

DOCKERFILE=/home/ubuntu/image-lab/Dockerfile
[[ "$(cat /home/ubuntu/image-lab/VERSION)" == 2.0.0 ]] || { echo "Файл VERSION не обновлён"; exit 1; }
REQ_LINE=$(grep -nE '^COPY[[:space:]]+requirements\.txt' "$DOCKERFILE" | head -n1 | cut -d: -f1)
APP_LINE=$(grep -nE '^COPY[[:space:]].*(app\.py|VERSION)' "$DOCKERFILE" | head -n1 | cut -d: -f1)
[[ -n "$REQ_LINE" && -n "$APP_LINE" && "$REQ_LINE" -lt "$APP_LINE" ]] || { echo "Слой зависимостей должен предшествовать копированию приложения"; exit 1; }
V1=$(docker image inspect --format '{{.Id}}' image-lab:v1)
V2=$(docker image inspect --format '{{.Id}}' image-lab:v2)
LATEST=$(docker image inspect --format '{{.Id}}' image-lab:latest)
[[ "$V2" == "$LATEST" && "$V1" != "$V2" ]] || { echo "Теги v1, v2 и latest имеют неверные digest"; exit 1; }
[[ "$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.version"}}' image-lab:v2)" == 2.0.0 ]] || { echo "Отсутствует metadata версии 2.0.0"; exit 1; }
LAYERS=$(docker image inspect --format '{{len .RootFS.Layers}}' image-lab:v2)
[[ "$LAYERS" -ge 3 ]] || { echo "В образе недостаточно различимых слоёв"; exit 1; }
curl --fail --silent --max-time 5 --retry 10 --retry-connrefused --retry-delay 1 http://127.0.0.1:18080/version | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"] == "2.0.0"'
