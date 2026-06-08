#!/usr/bin/env bash
set -euo pipefail

docker tag image-lab:build image-lab:v1
docker tag image-lab:build image-lab:latest
docker container rm --force image-lab-api >/dev/null 2>&1 || true
docker run --detach --name image-lab-api --publish 18080:8080 image-lab:latest >/dev/null
