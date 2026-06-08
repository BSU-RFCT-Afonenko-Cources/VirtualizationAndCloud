#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-shares
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/schedinfo-after.txt" || fail 'нет schedinfo-after.txt'
/usr/bin/grep -Eq 'cpu_shares[[:space:]]*:[[:space:]]*512' "$DIR/schedinfo-after.txt" || fail 'cpu_shares не равен 512'
