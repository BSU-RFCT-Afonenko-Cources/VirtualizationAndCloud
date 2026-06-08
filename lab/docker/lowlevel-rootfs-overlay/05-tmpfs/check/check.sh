#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/rootfs-lab/evidence
python3 -c "import json; d=json.load(open('$E/tmpfs.json')); assert d['mount_type']=='tmpfs' and d['state_absent_after_remount'] is True and d['base_artifact_absent'] is True"
grep -q ' tmpfs ' "$E/tmpfs.mountinfo" || { echo "В mountinfo нет tmpfs"; exit 1; }
test ! -e /home/ubuntu/rootfs-lab/rootfs-lab-base/run/lab/process.state || { echo "Runtime state попал в base"; exit 1; }
