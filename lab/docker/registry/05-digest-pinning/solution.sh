#!/bin/bash
set -euo pipefail

digest=$(/usr/bin/curl --fail --silent --head --header 'Accept: application/vnd.docker.distribution.manifest.v2+json' http://127.0.0.1:5000/v2/course/api/manifests/v1 | /usr/bin/awk -F': ' 'tolower($1)=="docker-content-digest" {gsub("\r", "", $2); print $2}')
reference="localhost:5000/course/api@${digest}"
/usr/bin/jq --null-input --arg repository 'localhost:5000/course/api' --arg tag 'v1' --arg digest "$digest" --arg reference "$reference" --arg container 'registry-api-digest' '{repository:$repository,tag:$tag,digest:$digest,reference:$reference,container:$container}' > /home/ubuntu/registry/digest.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/registry/digest.json
/usr/bin/docker rm --force registry-api-digest >/dev/null 2>&1 || true
/usr/bin/docker run --detach --name registry-api-digest --publish 18080:8080 "$reference"
for attempt in $(/usr/bin/seq 1 30); do
  [ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' registry-api-digest 2>/dev/null || true)" = "healthy" ] && exit 0
  /usr/bin/sleep 1
done
echo "API v1 не перешёл в healthy-состояние"
exit 1
