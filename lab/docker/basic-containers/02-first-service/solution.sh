#!/bin/bash
set -euo pipefail
if ! /usr/bin/docker network inspect lab-net >/dev/null 2>&1; then /usr/bin/docker network create --driver bridge --label com.course.lab=basic-containers lab-net >/dev/null; fi
if /usr/bin/docker container inspect lab-http >/dev/null 2>&1; then /usr/bin/docker container rm --force lab-http >/dev/null; fi
/usr/bin/docker run --detach --name lab-http --label com.course.lab=basic-containers --network lab-net --publish 18080:8080 lab-http-image:1.0 >/dev/null
for attempt in $(/usr/bin/seq 1 30); do if [ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' lab-http)" = healthy ] && /usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -e '.service == "lab-http"' >/dev/null 2>&1; then exit 0; fi; /usr/bin/sleep 1; done
exit 1
