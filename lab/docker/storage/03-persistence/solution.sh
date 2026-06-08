#!/bin/bash
set -euo pipefail
/usr/bin/docker exec storage-db /bin/sh -c 'printf "%s\n" "[{\"id\":\"persistent-1\",\"value\":\"survived-recreate\"}]" > /data/records.json'
/usr/bin/docker rm -f storage-db >/dev/null
/usr/bin/docker rm -f storage-db-v2 >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker run -d --name storage-db-v2 --mount type=volume,src=lab-data,dst=/data alpine:3.20 /bin/sh -c 'while :; do sleep 3600; done' >/dev/null
