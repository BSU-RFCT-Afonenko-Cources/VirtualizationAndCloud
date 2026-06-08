#!/usr/bin/env bash
set -euo pipefail

V1=$(docker image inspect --format '{{.Id}}' image-lab:v1)
LATEST=$(docker image inspect --format '{{.Id}}' image-lab:latest)
[[ "$V1" == "$LATEST" ]] || { echo "Теги v1 и latest указывают на разные образы"; exit 1; }
[[ "$(docker inspect --format '{{.Config.Image}}' image-lab-api)" == image-lab:latest ]] || { echo "Контейнер создан не из image-lab:latest"; exit 1; }
curl --fail --silent --max-time 5 --retry 10 --retry-connrefused --retry-delay 1 http://127.0.0.1:18080/version | python3 -c 'import json,sys; assert json.load(sys.stdin)["version"] == "1.0.0"'
