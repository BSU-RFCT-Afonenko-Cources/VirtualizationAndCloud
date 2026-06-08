#!/bin/bash
set -euo pipefail
container_id="$(/usr/bin/docker inspect --format '{{.Id}}' lab-http)"
before="$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)"
/usr/bin/docker stop lab-http >/dev/null
stopped="$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)"
/usr/bin/docker start lab-http >/dev/null
for attempt in $(/usr/bin/seq 1 30); do if service="$(/usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -r '.service' 2>/dev/null)"; then break; fi; /usr/bin/sleep 1; done
after="$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)"
control="$(/usr/bin/docker exec lab-http /bin/cat /tmp/lab-control.txt)"
/usr/bin/jq -n --arg containerId "$container_id" --argjson before "$before" --argjson stopped "$stopped" --argjson after "$after" --arg httpService "$service" --arg controlFile "$control" '{containerId:$containerId,before:$before,stopped:$stopped,after:$after,httpService:$httpService,controlFile:$controlFile}' > /home/ubuntu/basic-containers/evidence/06-lifecycle.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/06-lifecycle.json
