#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-delete-cleanup
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/final-vol-list-details.txt" || fail "нет final-vol-list-details.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true
for vol in lab-overlay.qcow2 lab-disk-clone.qcow2 lab-from-xml.qcow2 lab-sparse.qcow2 lab-raw.img lab-disk.qcow2 manual-volume.qcow2 generated-by-args.qcow2; do
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool "$vol" >/dev/null 2>&1; then fail "$vol всё ещё существует"; fi
  if /usr/bin/test -e "/tmp/libvirt-lab-pool/$vol"; then fail "файл /tmp/libvirt-lab-pool/$vol всё ещё существует"; fi
done
