#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/external-disk-snapshot
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in snapshot-list.txt lab-ext-001.xml domblklist-after.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
/usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-ext-001 >/dev/null 2>&1 || fail 'metadata lab-ext-001 отсутствует'
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
/usr/bin/test "$ACTIVE" = /tmp/libvirt-snapshots/lab-ext-001.qcow2 || fail 'active source vda не lab-ext-001.qcow2'
/usr/bin/test -f "$ACTIVE" || fail 'overlay lab-ext-001.qcow2 не существует'
/usr/bin/grep -q 'lab-ext-001' "$DIR/lab-ext-001.xml" || fail 'dumpxml не содержит имя snapshot'
