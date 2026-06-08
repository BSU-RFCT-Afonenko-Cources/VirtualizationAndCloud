#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage/backups
if ! /usr/bin/docker volume inspect storage-keep >/dev/null 2>&1; then
  /usr/bin/docker volume create --label course.keep=true storage-keep >/dev/null
fi
/usr/bin/docker run --rm --mount type=volume,src=storage-keep,dst=/keep alpine:3.20 /bin/sh -c '/usr/bin/printf "%s\n" "do-not-delete" > /keep/protected.txt'
