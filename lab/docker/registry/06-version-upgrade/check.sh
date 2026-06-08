#!/bin/bash
set -euo pipefail

tags=$(/usr/bin/curl --fail --silent http://127.0.0.1:5000/v2/course/api/tags/list)
/usr/bin/jq -e '.tags | index("v1") != null and index("v2") != null' <<<"$tags" >/dev/null || { echo "Registry должен хранить теги v1 и v2"; exit 1; }
manifest_digest() {
  /usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' "http://127.0.0.1:5000/v2/course/api/manifests/$1" | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}'
}
v1_digest=$(manifest_digest v1)
v2_digest=$(manifest_digest v2)
[[ "$v1_digest" =~ ^sha256:[0-9a-f]{64}$ && "$v2_digest" =~ ^sha256:[0-9a-f]{64}$ && "$v1_digest" != "$v2_digest" ]] || { echo "v1 и v2 должны иметь разные корректные digest"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.Config.Image}}' registry-api-v2 2>/dev/null || true)" = "localhost:5000/course/api:v2" ] || { echo "registry-api-v2 должен быть создан из registry-тега v2"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' registry-api-v2)" = "true" ] || { echo "registry-api-v2 не запущен"; exit 1; }
[ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' registry-api-v2)" = "healthy" ] || { echo "registry-api-v2 не healthy"; exit 1; }
port=$(/usr/bin/docker inspect --format '{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' registry-api-v2)
[ "$port" = "18081" ] || { echo "API v2 должен быть опубликован на порту 18081"; exit 1; }
/usr/bin/curl --fail --silent http://127.0.0.1:18081/version | /usr/bin/jq -e '.version == "v2" and .service == "course-registry-api"' >/dev/null || { echo "Endpoint не возвращает версию v2"; exit 1; }
