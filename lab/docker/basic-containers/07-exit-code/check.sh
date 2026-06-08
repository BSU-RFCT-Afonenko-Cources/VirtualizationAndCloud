#!/bin/bash
set -euo pipefail
test "$(/usr/bin/docker inspect --format '{{.State.Status}}' lab-job)" = exited
test "$(/usr/bin/docker inspect --format '{{.State.ExitCode}}' lab-job)" = 0
test "$(/usr/bin/tr -d '[:space:]' < /home/ubuntu/basic-containers/evidence/07-exit-code.txt)" = 0
/usr/bin/jq -e '.service == "lab-http" and .endpoint == "/diagnostic" and .query == "source=lab-job"' /home/ubuntu/basic-containers/evidence/07-job-output.json >/dev/null
