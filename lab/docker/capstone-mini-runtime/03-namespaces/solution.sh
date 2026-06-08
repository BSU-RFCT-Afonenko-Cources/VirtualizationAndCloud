#!/bin/bash
set -euo pipefail
[ -d /home/ubuntu/mini-runtime/rootfs ] || /usr/local/lib/mini-runtime-lab/reference-runtime.sh rootfs
/usr/local/lib/mini-runtime-lab/reference-runtime.sh start
