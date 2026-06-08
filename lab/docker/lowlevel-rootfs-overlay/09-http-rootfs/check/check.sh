#!/usr/bin/env bash
set -euo pipefail
S=/home/ubuntu/rootfs-lab/state/http.pid
test -s "$S" && kill -0 "$(cat "$S")" || { echo "HTTP-процесс не работает"; exit 1; }
grep -q 'upper-layer: changed' /home/ubuntu/rootfs-lab/evidence/http-response.txt || { echo "HTTP не отдаёт upper-версию"; exit 1; }
grep -q 'base-layer: original' /home/ubuntu/rootfs-lab/rootfs-lab-base/var/www/index.html || { echo "Base layer изменён"; exit 1; }
python3 -c "import json,os; d=json.load(open('/home/ubuntu/rootfs-lab/evidence/http.json')); assert d['pid'] > 1 and d['base_unchanged'] is True and os.path.exists('/proc/%s/ns/mnt' % d['pid'])"
grep -q '/home/ubuntu/rootfs-lab/runtime/http-rootfs' /home/ubuntu/rootfs-lab/evidence/http.mountinfo || { echo "Mountinfo процесса не содержит runtime rootfs"; exit 1; }
