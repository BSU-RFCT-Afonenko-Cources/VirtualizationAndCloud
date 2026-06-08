#!/bin/bash
set -euo pipefail

/usr/bin/docker rm --force registry-api-digest registry-api-v2 >/dev/null 2>&1 || true
mapfile -t digest_refs < <(
  /usr/bin/docker image ls --quiet | /usr/bin/sort --unique | while read -r image_id; do
    /usr/bin/docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$image_id"
  done | /usr/bin/awk '$0 ~ /^localhost:5000\/course\/api@sha256:/' | /usr/bin/sort --unique
)
if [ "${#digest_refs[@]}" -gt 0 ]; then
  /usr/bin/docker image rm "${digest_refs[@]}" >/dev/null
fi
mapfile -t image_refs < <(/usr/bin/docker image ls --format '{{.Repository}}:{{.Tag}}' | /usr/bin/awk '$0 ~ /^localhost:5000\/course\/api:/')
if [ "${#image_refs[@]}" -gt 0 ]; then
  /usr/bin/docker image rm "${image_refs[@]}" >/dev/null
fi
