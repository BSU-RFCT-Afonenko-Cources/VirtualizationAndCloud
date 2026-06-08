#!/bin/bash
set -euo pipefail
test "$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)" = true
test "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' lab-http)" = healthy
test "$(/usr/bin/docker inspect --format '{{index .Config.Labels "com.course.lab"}}' lab-http)" = basic-containers
/usr/bin/docker inspect --format '{{json .NetworkSettings.Networks}}' lab-http | /usr/bin/jq -e 'has("lab-net")' >/dev/null
/usr/bin/docker inspect --format '{{json .NetworkSettings.Ports}}' lab-http | /usr/bin/jq -e '.["8080/tcp"] | any(.[]; .HostPort == "18080")' >/dev/null
/usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -e '.service == "lab-http"' >/dev/null
