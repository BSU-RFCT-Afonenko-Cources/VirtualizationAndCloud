#!/bin/bash
set -euo pipefail
test "$(/usr/bin/docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' lab-http)" = unless-stopped
test "$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)" = true
/usr/bin/jq -e '.policy == "unless-stopped" and .restartCountAfter > .restartCountBefore and .running == true and .service == "lab-http"' /home/ubuntu/basic-containers/evidence/08-restart.json >/dev/null
/usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -e '.service == "lab-http"' >/dev/null
