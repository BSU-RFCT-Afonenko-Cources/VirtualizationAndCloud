#!/usr/bin/env bash
set -euo pipefail
L=/home/ubuntu/rootfs-lab/overlay/lower
U=/home/ubuntu/rootfs-lab/overlay/upper
M=/home/ubuntu/rootfs-lab/overlay/merged
test -d "$L" || { echo "Нет lower"; exit 1; }
mountpoint -q "$M" || { echo "merged не смонтирован"; exit 1; }
grep -q 'base-layer: original' "$L/var/www/index.html" || { echo "lower изменён"; exit 1; }
grep -q 'upper-layer: changed' "$U/var/www/index.html" || { echo "copy-up не найден в upper"; exit 1; }
grep -q 'upper-layer: changed' "$M/var/www/index.html" || { echo "merged не показывает upper-версию"; exit 1; }
test -f "$U/var/www/upper.txt" || { echo "Новый файл не создан в upper"; exit 1; }
grep -q ' overlay ' /home/ubuntu/rootfs-lab/evidence/overlay.mountinfo || { echo "Нет overlay в mountinfo"; exit 1; }
