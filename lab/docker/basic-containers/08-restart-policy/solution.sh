#!/bin/bash
set -euo pipefail
/usr/bin/docker update --restart unless-stopped lab-http >/dev/null
before="$(/usr/bin/docker inspect --format '{{.RestartCount}}' lab-http)"
/usr/bin/docker kill --signal KILL lab-http >/dev/null
for attempt in $(/usr/bin/seq 1 45); do
  running="$(/usr/bin/docker inspect --format '{{.State.Running}}' lab-http)"
  after="$(/usr/bin/docker inspect --format '{{.RestartCount}}' lab-http)"
  if [ "$running" = true ] && [ "$after" -gt "$before" ] && service="$(/usr/bin/curl --fail --silent http://127.0.0.1:18080/ | /usr/bin/jq -r '.service' 2>/dev/null)"; then break; fi
  /usr/bin/sleep 1
done
policy="$(/usr/bin/docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' lab-http)"
/usr/bin/jq -n --arg policy "$policy" --argjson before "$before" --argjson after "$after" --argjson running "$running" --arg service "$service" '{policy:$policy,restartCountBefore:$before,restartCountAfter:$after,running:$running,service:$service}' > /home/ubuntu/basic-containers/evidence/08-restart.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/08-restart.json
/usr/bin/jq -e '.restartCountAfter > .restartCountBefore and .running == true and .service == "lab-http"' /home/ubuntu/basic-containers/evidence/08-restart.json >/dev/null
