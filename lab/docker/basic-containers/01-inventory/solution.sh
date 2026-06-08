#!/bin/bash
set -euo pipefail
/usr/bin/install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu/basic-containers/evidence
/usr/bin/docker info --format '{{json .}}' | /usr/bin/jq . > /home/ubuntu/basic-containers/evidence/engine.json
/usr/bin/docker image inspect $(/usr/bin/docker image ls --quiet --no-trunc | /usr/bin/sort -u) > /home/ubuntu/basic-containers/evidence/images.json
container_ids="$(/usr/bin/docker container ls --all --quiet --no-trunc)"
if [ -n "$container_ids" ]; then /usr/bin/docker container inspect $container_ids > /home/ubuntu/basic-containers/evidence/containers.json; else printf '[]
' > /home/ubuntu/basic-containers/evidence/containers.json; fi
/usr/bin/docker network inspect $(/usr/bin/docker network ls --quiet --no-trunc) > /home/ubuntu/basic-containers/evidence/networks.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/engine.json /home/ubuntu/basic-containers/evidence/images.json /home/ubuntu/basic-containers/evidence/containers.json /home/ubuntu/basic-containers/evidence/networks.json
