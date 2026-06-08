#!/bin/bash
set -euo pipefail
/usr/bin/docker rm -f storage-db >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker volume rm lab-data >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker volume create --label course.lab=storage lab-data >/dev/null
/usr/bin/docker run -d --name storage-db --mount type=volume,src=lab-data,dst=/data alpine:3.20 /bin/sh -c 'while :; do sleep 3600; done' >/dev/null
