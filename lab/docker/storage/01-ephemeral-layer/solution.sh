#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage/evidence
/usr/bin/docker rm -f storage-ephemeral >/dev/null 2>&1 || /usr/bin/true
/usr/bin/docker run -d --name storage-ephemeral alpine:3.20 /bin/sh -c 'printf "%s\n" "writable-layer-data" > /tmp/ephemeral-marker; while :; do sleep 3600; done' >/dev/null
before_id=$(/usr/bin/docker inspect --format '{{.Id}}' storage-ephemeral)
/usr/bin/printf '{"container_id":"%s","marker":"writable-layer-data","marker_present":true}
' "$before_id" > /home/ubuntu/storage/evidence/ephemeral-before.json
/usr/bin/docker rm -f storage-ephemeral >/dev/null
/usr/bin/docker run -d --name storage-ephemeral alpine:3.20 /bin/sh -c 'while :; do sleep 3600; done' >/dev/null
after_id=$(/usr/bin/docker inspect --format '{{.Id}}' storage-ephemeral)
/usr/bin/printf '{"container_id":"%s","marker_present":false}
' "$after_id" > /home/ubuntu/storage/evidence/ephemeral-after.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/storage/evidence/ephemeral-before.json /home/ubuntu/storage/evidence/ephemeral-after.json
