#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/start-nat-network
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in net-list.txt net-info-lab-nat.txt lab-nat-active.xml virbr10-link.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
info=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-nat 2>/dev/null) || fail 'сеть lab-nat не определена'
/bin/echo "$info" | /usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes' || fail 'lab-nat должна быть active'
/bin/echo "$info" | /usr/bin/grep -Eq 'Persistent:[[:space:]]+yes|Постоянная:[[:space:]]+да|Постоянная:[[:space:]]+yes' || fail 'lab-nat должна быть persistent'
/bin/echo "$info" | /usr/bin/grep -Eq 'Autostart:[[:space:]]+yes|Автозапуск:[[:space:]]+да|Автозапуск:[[:space:]]+yes' || fail 'lab-nat должна иметь autostart'
/usr/sbin/ip link show virbr10 >/dev/null 2>&1 || fail 'bridge virbr10 не существует'
/usr/bin/grep -q '<name>lab-nat</name>' "$DIR/lab-nat-active.xml" || fail 'lab-nat-active.xml должен содержать lab-nat'
