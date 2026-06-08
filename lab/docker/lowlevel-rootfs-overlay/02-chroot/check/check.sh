#!/usr/bin/env bash
set -euo pipefail
E=/home/ubuntu/rootfs-lab/evidence/chroot.json
test -s "$E" || { echo "Нет chroot evidence"; exit 1; }
python3 -c "import json; d=json.load(open('$E')); assert d['experiment']=='chroot' and d['same_pid_namespace'] is True and d['proc_pid_1_visible'] is True and d['network_namespace_created'] is False and d['host_pid_namespace']==d['chroot_pid_namespace']"
