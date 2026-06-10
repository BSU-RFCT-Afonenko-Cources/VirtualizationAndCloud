#!/bin/bash
set -euo pipefail
test "$(/usr/bin/docker exec lab-http /bin/cat /home/ubuntu/basic-containers/lab-control.txt)" = writable-layer-ok
test "$(/bin/cat /home/ubuntu/basic-containers/evidence/05-control.txt)" = writable-layer-ok
