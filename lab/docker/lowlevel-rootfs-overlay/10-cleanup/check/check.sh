#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/rootfs-lab/evidence/cleanup.json
test -s "$E" || { echo "Нет cleanup evidence"; exit 1; }
python3 -c "import json; d=json.load(open('$E')); assert all(d.values())"
if test -s /home/ubuntu/rootfs-lab/state/http.pid && kill -0 "$(cat /home/ubuntu/rootfs-lab/state/http.pid)" 2>/dev/null; then echo "HTTP-процесс остался"; exit 1; fi
if test -s /home/ubuntu/rootfs-lab/state/mountns.pid && kill -0 "$(cat /home/ubuntu/rootfs-lab/state/mountns.pid)" 2>/dev/null; then echo "Keeper-процесс остался"; exit 1; fi
if findmnt -R /home/ubuntu/rootfs-lab/overlay/merged >/dev/null 2>&1; then echo "Остался mount overlay/merged"; exit 1; fi
