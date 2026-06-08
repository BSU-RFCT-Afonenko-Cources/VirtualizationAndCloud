#!/usr/bin/env bash
set -euo pipefail
S=/home/ubuntu/rootfs-lab/state/mountns.pid
E=/home/ubuntu/rootfs-lab/evidence
test -s "$S" && kill -0 "$(cat "$S")" || { echo "Mount namespace keeper не работает"; exit 1; }
python3 -c "import json; d=json.load(open('$E/mountns.json')); assert d['host'] != d['experiment'] and d['different'] is True"
grep -q '/home/ubuntu/rootfs-lab/runtime/rootfs ' "$E/mountns.mountinfo" || { echo "Нет bind rootfs в mountinfo"; exit 1; }
grep -q '/home/ubuntu/rootfs-lab/runtime/rootfs/proc ' "$E/mountns.mountinfo" || { echo "Нет proc в rootfs"; exit 1; }
