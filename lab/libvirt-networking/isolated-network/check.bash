#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/isolated-network
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-private.xml net-info-lab-private.txt lab-private-active.xml virbr20-addr.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private >/var/tmp/lab-private-info 2>/dev/null || fail 'сеть lab-private не определена'
/usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes' /var/tmp/lab-private-info || fail 'lab-private должна быть active'
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-private >/var/tmp/lab-private.xml
! /usr/bin/grep -q '<forward' /var/tmp/lab-private.xml || fail 'isolated сеть не должна содержать <forward>'
/usr/sbin/ip addr show virbr20 | /usr/bin/grep -q '10\.20\.0\.1/24' || fail 'virbr20 должен иметь адрес 10.20.0.1/24'
/usr/bin/grep -q '<name>lab-private</name>' "$DIR/lab-private-active.xml" || fail 'lab-private-active.xml должен содержать XML сети'
