#!/usr/bin/env bash
set -euo pipefail

docker container rm --force image-lab-api >/dev/null
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:v2 >/dev/null
