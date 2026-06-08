#!/bin/bash
set -euo pipefail
if /usr/bin/docker container inspect lab-job >/dev/null 2>&1; then /usr/bin/docker container rm --force lab-job >/dev/null; fi
/usr/bin/docker create --name lab-job --label com.course.lab=basic-containers --network lab-net curlimages/curl:8.12.1 --fail --silent 'http://lab-http:8080/diagnostic?source=lab-job' >/dev/null
/usr/bin/docker start --attach lab-job > /home/ubuntu/basic-containers/evidence/07-job-output.json
/usr/bin/docker inspect --format '{{.State.ExitCode}}' lab-job > /home/ubuntu/basic-containers/evidence/07-exit-code.txt
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/07-job-output.json /home/ubuntu/basic-containers/evidence/07-exit-code.txt
