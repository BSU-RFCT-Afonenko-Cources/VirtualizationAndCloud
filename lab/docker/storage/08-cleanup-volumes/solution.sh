#!/bin/bash
set -euo pipefail
for container in storage-db storage-db-v2 storage-api storage-init storage-backup storage-restore storage-api-restore; do
  /usr/bin/docker rm -f "$container" >/dev/null 2>&1 || /usr/bin/true
done
for volume in $(/usr/bin/docker volume ls --format '{{.Name}}' --filter name='^lab-data'); do
  case "$volume" in
    lab-data*) /usr/bin/docker volume rm "$volume" >/dev/null ;;
  esac
done
