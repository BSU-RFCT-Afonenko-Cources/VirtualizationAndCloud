#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage
/usr/bin/docker image inspect alpine:3.20 >/dev/null 2>&1 || /usr/bin/docker pull alpine:3.20
/usr/bin/docker volume inspect lab-data >/dev/null
/usr/bin/docker inspect storage-db >/dev/null
/usr/bin/docker rm -f storage-db-v2 >/dev/null 2>&1 || /usr/bin/true
