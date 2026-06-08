#!/bin/bash
set -euo pipefail
/usr/bin/jq -e '.containerId | type == "string" and length > 0' /home/ubuntu/basic-containers/evidence/06-lifecycle.json >/dev/null
/usr/bin/jq -e '.before == true and .stopped == false and .after == true and .httpService == "lab-http" and .controlFile == "writable-layer-ok"' /home/ubuntu/basic-containers/evidence/06-lifecycle.json >/dev/null
test "$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)" = true
test "$(/usr/bin/docker inspect --format '{{.Id}}' lab-http)" = "$(/usr/bin/jq -r '.containerId' /home/ubuntu/basic-containers/evidence/06-lifecycle.json)"
/usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -e '.service == "lab-http"' >/dev/null
