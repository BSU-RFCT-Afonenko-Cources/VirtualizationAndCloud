#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-refresh
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in vol-list-before.txt vol-list-after.txt vol-info-manual.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/test -f /tmp/libvirt-lab-pool/manual.qcow2 || fail "manual.qcow2 не создан"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool >/var/tmp/lab-pool-vol-list-refresh 2>&1 || fail "не удалось получить vol-list lab-pool"
/usr/bin/grep -q 'manual.qcow2' /var/tmp/lab-pool-vol-list-refresh || fail "manual.qcow2 не виден в vol-list после refresh"
/usr/bin/grep -q 'manual.qcow2' "$DIR/vol-list-after.txt" || fail "vol-list-after.txt должен содержать manual.qcow2"
