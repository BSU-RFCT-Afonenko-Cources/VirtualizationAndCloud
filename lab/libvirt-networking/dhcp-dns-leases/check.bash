#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/dhcp-dns-leases
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-nat-leases.txt lab-private-leases.txt lab-vm-domifaddr.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/grep -Eq 'MAC|52:54:00|no active clients|Address|IP|адрес|нет|absent|no reported' "$DIR/lab-nat-leases.txt" || fail 'lab-nat-leases.txt не содержит leases или диагностику отсутствия клиентов'
/usr/bin/grep -Eq 'MAC|52:54:00|no active clients|Address|IP|адрес|нет|absent|no reported' "$DIR/lab-private-leases.txt" || fail 'lab-private-leases.txt не содержит leases или диагностику отсутствия клиентов'
/usr/bin/grep -Eq 'Name|MAC|52:54:00|absent|no reported|Address|адрес|нет' "$DIR/lab-vm-domifaddr.txt" || fail 'lab-vm-domifaddr.txt не содержит вывод domifaddr или диагностику'
