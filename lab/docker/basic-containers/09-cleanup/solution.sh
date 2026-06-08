#!/bin/bash
set -euo pipefail
for container in lab-http lab-job; do if /usr/bin/docker container inspect "$container" >/dev/null 2>&1; then /usr/bin/docker container rm --force "$container" >/dev/null; fi; done
if /usr/bin/docker network inspect lab-net >/dev/null 2>&1; then /usr/bin/docker network rm lab-net >/dev/null; fi
if /usr/bin/docker image inspect lab-http-image:1.0 >/dev/null 2>&1; then /usr/bin/docker image rm lab-http-image:1.0 >/dev/null; fi
