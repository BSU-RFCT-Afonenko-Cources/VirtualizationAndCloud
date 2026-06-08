#!/bin/bash
set -euo pipefail

image_id=$(/usr/bin/docker image inspect --format '{{.Id}}' localhost:5000/course/api:v1 2>/dev/null || true)
[ -n "$image_id" ] || { echo "Образ localhost:5000/course/api:v1 не загружен"; exit 1; }
registry_digest=$(/usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' http://127.0.0.1:5000/v2/course/api/manifests/v1 | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}')
repo_digests=$(/usr/bin/docker image inspect --format '{{json .RepoDigests}}' localhost:5000/course/api:v1)
/usr/bin/jq -e --arg expected "localhost:5000/course/api@${registry_digest}" 'index($expected) != null' <<<"$repo_digests" >/dev/null || { echo "RepoDigest локального образа не совпадает с registry"; exit 1; }
