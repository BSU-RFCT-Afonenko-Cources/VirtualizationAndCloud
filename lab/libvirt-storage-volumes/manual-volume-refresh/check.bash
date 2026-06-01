#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/manual-volume-refresh
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in vol-list-before-refresh.txt vol-list-after-refresh.txt vol-info-manual-volume.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -q 'manual-volume.qcow2' "$DIR/vol-list-after-refresh.txt" || fail "manual-volume.qcow2 должен появиться после pool-refresh"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool manual-volume.qcow2 >/dev/null || fail "libvirt не видит manual-volume.qcow2"
