#!/usr/bin/env bash
set -euo pipefail
L=/home/ubuntu/rootfs-lab/rootfs-lab-base/var/www/obsolete.txt
M=/home/ubuntu/rootfs-lab/overlay/merged/var/www/obsolete.txt
test -f "$L" || { echo "lower-файл удалён"; exit 1; }
test ! -e "$M" || { echo "Файл всё ещё виден в merged"; exit 1; }
python3 -c "import json; d=json.load(open('/home/ubuntu/rootfs-lab/evidence/whiteout.json')); assert d['lower_exists'] is True and d['merged_absent'] is True and d['upper_marker']"
grep -q 'obsolete' /home/ubuntu/rootfs-lab/evidence/upper-state.txt || { echo "Upper-state не отражает удаление"; exit 1; }
