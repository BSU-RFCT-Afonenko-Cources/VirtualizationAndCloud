#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/no-metadata-snapshot
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in snapshot-names-before.txt snapshot-names-after.txt domblklist-after.txt no-metadata-result.txt; do /usr/bin/test -e "$DIR/$file" || fail "нет файла $file"; done
/usr/bin/test -s "$DIR/domblklist-after.txt" || fail 'domblklist-after.txt пуст'
! /usr/bin/grep -qx 'lab-nometa-001' "$DIR/snapshot-names-after.txt" || fail 'no-metadata snapshot появился в metadata list'
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
/usr/bin/test "$ACTIVE" = /home/ubuntu/no-metadata-snapshot/libvirt-snapshots/lab-nometa-001.qcow2 || fail 'active source не lab-nometa-001.qcow2'
/usr/bin/test -f "$ACTIVE" || fail 'no-metadata overlay отсутствует'
