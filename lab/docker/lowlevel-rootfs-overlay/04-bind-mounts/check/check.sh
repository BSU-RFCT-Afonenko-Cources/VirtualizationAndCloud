#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/rootfs-lab/evidence
python3 -c "import json; d=json.load(open('$E/binds.json')); assert d['readonly_write_denied'] is True and d['readwrite_write_succeeded'] is True"
grep -q '/home/ubuntu/rootfs-lab/config' "$E/binds.mountinfo" || { echo "Нет bind mount config"; exit 1; }
grep -q '/home/ubuntu/rootfs-lab/data' "$E/binds.mountinfo" || { echo "Нет bind mount data"; exit 1; }
grep -q 'rw-write' /home/ubuntu/rootfs-lab/host-data/events.log || { echo "Запись в read-write bind не появилась на host"; exit 1; }
