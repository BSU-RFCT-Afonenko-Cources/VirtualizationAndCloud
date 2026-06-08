#!/bin/bash
set -euo pipefail
if /usr/bin/docker volume ls --format '{{.Name}}' | /usr/bin/grep -Eq '^lab-data'; then
  /usr/bin/echo 'Остались volumes с префиксом lab-data'
  exit 1
fi
/usr/bin/docker volume inspect storage-keep >/dev/null
[ "$(/usr/bin/docker volume inspect --format '{{index .Labels "course.keep"}}' storage-keep)" = true ] || { /usr/bin/echo 'Повреждён контрольный volume'; exit 1; }
marker=$(/usr/bin/docker run --rm --mount type=volume,src=storage-keep,dst=/keep,readonly alpine:3.20 /bin/cat /keep/protected.txt)
[ "$marker" = do-not-delete ] || { /usr/bin/echo 'Контрольные данные удалены'; exit 1; }
/usr/bin/test -s /home/ubuntu/storage/backups/lab-data.tar.gz
/usr/bin/test -s /home/ubuntu/storage/backups/lab-data.tar.gz.sha256
for container in storage-db storage-db-v2 storage-api storage-init storage-backup storage-restore storage-api-restore; do
  if /usr/bin/docker inspect "$container" >/dev/null 2>&1; then
    /usr/bin/echo "Остался лабораторный контейнер $container"
    exit 1
  fi
done
