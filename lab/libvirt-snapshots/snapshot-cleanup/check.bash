#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-cleanup
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in snapshot-list-final.txt domblklist-final.txt disk-info-final.txt cleanup-results.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
BASE=$(/usr/bin/sed -n 's/^BASE_DISK=//p' /home/ubuntu/snapshot-baseline/baseline.env)
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
/usr/bin/test "$ACTIVE" = "$BASE" || fail "active source $ACTIVE не равен исходному $BASE"
LEFT=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name | /usr/bin/grep '^lab-' || true)
/usr/bin/test -z "$LEFT" || fail 'остались snapshot metadata с префиксом lab-'
if /usr/bin/find /tmp/libvirt-snapshots -maxdepth 1 -type f \( -name 'lab-*.qcow2' -o -name 'lab-*.memory' \) -print -quit | /usr/bin/grep -q .; then fail 'остались временные overlay/memory files'; fi
