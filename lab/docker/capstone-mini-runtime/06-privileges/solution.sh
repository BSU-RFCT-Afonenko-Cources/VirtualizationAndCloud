#!/bin/bash
set -euo pipefail
[ -f /run/mini-runtime-lab/api.pid ] || /usr/local/lib/mini-runtime-lab/reference-runtime.sh start
/usr/local/lib/mini-runtime-lab/reference-runtime.sh evidence
