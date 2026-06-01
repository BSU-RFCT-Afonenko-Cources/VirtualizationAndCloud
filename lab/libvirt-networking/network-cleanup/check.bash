#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/network-cleanup
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in net-list-final.txt lab-vm-final.xml links-final.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-nat >/dev/null 2>&1; then fail 'сеть lab-nat всё ещё определена'; fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private >/dev/null 2>&1; then fail 'сеть lab-private всё ещё определена'; fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/var/tmp/lab-vm-final.xml 2>/dev/null; then
  ! /usr/bin/grep -q '52:54:00:aa:10:01\|52:54:00:aa:20:01' /var/tmp/lab-vm-final.xml || fail 'лабораторные MAC всё ещё присутствуют в XML lab-vm'
fi
! /usr/sbin/ip link show virbr10 >/dev/null 2>&1 || fail 'bridge virbr10 всё ещё существует'
! /usr/sbin/ip link show virbr20 >/dev/null 2>&1 || fail 'bridge virbr20 всё ещё существует'
