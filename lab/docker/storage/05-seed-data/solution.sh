#!/bin/bash
set -euo pipefail
/usr/bin/docker rm -f storage-init >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker run --name storage-init --label course.role=init --mount type=volume,src=lab-data,dst=/data alpine:3.20 /bin/sh -c 'printf "%s\n" "[{\"id\":\"seed-1\",\"value\":\"alpha\"},{\"id\":\"seed-2\",\"value\":\"beta\"},{\"id\":\"seed-3\",\"value\":\"gamma\"}]" > /data/records.json'
