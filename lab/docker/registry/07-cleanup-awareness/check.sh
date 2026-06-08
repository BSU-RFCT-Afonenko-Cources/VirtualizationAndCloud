#!/bin/bash
set -euo pipefail

for container in registry-api-digest registry-api-v2; do
  if /usr/bin/docker inspect "$container" >/dev/null 2>&1; then
    echo "Контейнер $container не удалён"
    exit 1
  fi
done
[ "$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-registry 2>/dev/null || true)" = "true" ] || { echo "lab-registry должен остаться запущенным"; exit 1; }
if /usr/bin/docker image ls --format '{{.Repository}}:{{.Tag}}' | /usr/bin/awk '$0 ~ /^localhost:5000\/course\/api:/ {found=1} END {exit !found}'; then
  echo "Локальные теги localhost:5000/course/api ещё существуют"
  exit 1
fi
if /usr/bin/docker image ls --quiet | /usr/bin/sort --unique | while read -r image_id; do /usr/bin/docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$image_id"; done | /usr/bin/awk '$0 ~ /^localhost:5000\/course\/api@sha256:/ {found=1} END {exit !found}'; then
  echo "Локальные digest-ссылки localhost:5000/course/api ещё существуют"
  exit 1
fi
tags=$(/usr/bin/curl --fail --silent http://127.0.0.1:5000/v2/course/api/tags/list)
/usr/bin/jq -e '.name == "course/api" and (.tags | index("v1") != null and index("v2") != null)' <<<"$tags" >/dev/null || { echo "Registry больше не хранит обе версии"; exit 1; }
for version in v1 v2; do
  digest=$(/usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' "http://127.0.0.1:5000/v2/course/api/manifests/${version}" | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}')
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || { echo "Manifest $version недоступен в registry"; exit 1; }
done
