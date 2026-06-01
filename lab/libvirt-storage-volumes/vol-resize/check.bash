#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-resize
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in vol-info-before.txt vol-info-after-512m.txt vol-info-after-delta.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
CAP=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-dumpxml --pool lab-pool --xpath 'string(/volume/capacity)' lab-disk.qcow2)
/usr/bin/test "$CAP" -gt 268435456 || fail "итоговая capacity должна быть больше 256M"
