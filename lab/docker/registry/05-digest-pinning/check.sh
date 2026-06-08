#!/bin/bash
set -euo pipefail

evidence=/home/ubuntu/registry/digest.json
[ -f "$evidence" ] || { echo "Отсутствует $evidence"; exit 1; }
/usr/bin/jq -e 'type == "object" and .repository == "localhost:5000/course/api" and .tag == "v1" and .container == "registry-api-digest" and (.digest | test("^sha256:[0-9a-f]{64}$")) and .reference == (.repository + "@" + .digest)' "$evidence" >/dev/null || { echo "digest.json имеет неверную структуру или значения"; exit 1; }
expected=$(/usr/bin/jq -r '.reference' "$evidence")
registry_digest=$(/usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' http://127.0.0.1:5000/v2/course/api/manifests/v1 | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}')
[ "$expected" = "localhost:5000/course/api@${registry_digest}" ] || { echo "Evidence не соответствует digest v1 в registry"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.Config.Image}}' registry-api-digest 2>/dev/null || true)" = "$expected" ] || { echo "Контейнер запущен не по immutable reference"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' registry-api-digest)" = "true" ] || { echo "Контейнер registry-api-digest не запущен"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' registry-api-digest)" = "healthy" ] || { echo "Контейнер registry-api-digest не healthy"; exit 1; }
port=$(/usr/bin/docker inspect --format '{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' registry-api-digest)
[ "$port" = "18080" ] || { echo "API должен быть опубликован на порту 18080"; exit 1; }
/usr/bin/curl --fail --silent http://127.0.0.1:18080/version | /usr/bin/jq -e '.version == "v1" and .service == "course-registry-api"' >/dev/null || { echo "Endpoint не возвращает версию v1"; exit 1; }
