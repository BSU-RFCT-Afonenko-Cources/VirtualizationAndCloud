#!/bin/bash
set -euo pipefail
/usr/bin/test -d /home/ubuntu/mini-runtime || /workspace/VirtualizationAndCloud/lab/docker/capstone-mini-runtime/prepare.sh
