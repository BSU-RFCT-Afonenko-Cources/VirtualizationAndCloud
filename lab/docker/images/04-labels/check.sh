#!/usr/bin/env bash
set -euo pipefail

IMAGE=image-lab:latest
[[ "$(docker image inspect --format '{{index .Config.Labels "maintainer"}}' "$IMAGE")" == student@course.local ]] || { echo "Неверный label maintainer"; exit 1; }
[[ "$(docker image inspect --format '{{index .Config.Labels "course"}}' "$IMAGE")" == virtualization-and-cloud ]] || { echo "Неверный label course"; exit 1; }
[[ "$(docker image inspect --format '{{index .Config.Labels "component"}}' "$IMAGE")" == image-lab-api ]] || { echo "Неверный label component"; exit 1; }
[[ "$(docker image inspect --format '{{.Id}}' image-lab:v1)" == "$(docker image inspect --format '{{.Id}}' image-lab:latest)" ]] || { echo "Теги v1 и latest не обновлены согласованно"; exit 1; }
