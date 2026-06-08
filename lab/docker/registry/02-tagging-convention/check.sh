#!/bin/bash
set -euo pipefail

source_id=$(/usr/bin/docker image inspect --format '{{.Id}}' course-registry-api:build-v1 2>/dev/null || true)
tagged_id=$(/usr/bin/docker image inspect --format '{{.Id}}' localhost:5000/course/api:v1 2>/dev/null || true)
[ -n "$source_id" ] || { echo "Не найден исходный образ course-registry-api:build-v1"; exit 1; }
[ "$tagged_id" = "$source_id" ] || { echo "Тег localhost:5000/course/api:v1 отсутствует или указывает не на исходный образ"; exit 1; }
