#!/bin/bash
set -euo pipefail
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/storage /home/ubuntu/storage/evidence
/usr/bin/docker image inspect alpine:3.20 >/dev/null 2>&1 || /usr/bin/docker pull alpine:3.20
/usr/bin/docker rm -f storage-ephemeral >/dev/null 2>&1 || /usr/bin/true
/usr/bin/rm -f /home/ubuntu/storage/evidence/ephemeral-before.json /home/ubuntu/storage/evidence/ephemeral-after.json
