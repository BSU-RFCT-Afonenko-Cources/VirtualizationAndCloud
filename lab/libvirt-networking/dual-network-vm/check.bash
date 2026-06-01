#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/dual-network-vm
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in domiflist.txt lab-vm-config.xml lab-private-leases.txt bridge-link.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/var/tmp/lab-vm-dual.xml 2>/dev/null || fail 'домен lab-vm не определён'
/usr/bin/grep -q '52:54:00:aa:10:01' /var/tmp/lab-vm-dual.xml || fail 'нет первого MAC 52:54:00:aa:10:01'
/usr/bin/grep -q '52:54:00:aa:20:01' /var/tmp/lab-vm-dual.xml || fail 'нет второго MAC 52:54:00:aa:20:01'
/usr/bin/grep -q "network='lab-nat'" /var/tmp/lab-vm-dual.xml || fail 'нет source network lab-nat'
/usr/bin/grep -q "network='lab-private'" /var/tmp/lab-vm-dual.xml || fail 'нет source network lab-private'
