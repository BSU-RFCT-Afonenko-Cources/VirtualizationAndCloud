#!/bin/bash
set -euo pipefail
/usr/bin/docker volume inspect lab-data >/dev/null
/usr/bin/docker inspect storage-api >/dev/null
/usr/bin/docker rm -f storage-init >/dev/null 2>&1 || /usr/bin/true
