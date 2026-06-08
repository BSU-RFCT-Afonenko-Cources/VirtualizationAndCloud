#!/usr/bin/env bash
set -euo pipefail
docker service update --quiet --limit-cpu 0.50 --limit-memory 256M lab-worker >/dev/null
