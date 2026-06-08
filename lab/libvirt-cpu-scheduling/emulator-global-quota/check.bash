#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/emulator-global-quota
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/schedinfo-after.txt" || fail 'нет schedinfo-after.txt'
if /usr/bin/grep -Eq '(emulator_period|global_period)[[:space:]]*:[[:space:]]*100000' "$DIR/schedinfo-after.txt" && /usr/bin/grep -Eq '(emulator_quota[[:space:]]*:[[:space:]]*80000|global_quota[[:space:]]*:[[:space:]]*90000)' "$DIR/schedinfo-after.txt"; then exit 0; fi
/usr/bin/test -s "$DIR/quota-error.txt" || fail 'нет новых значений и нет quota-error.txt'
/usr/bin/grep -Eiq 'unsupported|not supported|invalid|error|ошиб|не поддерж' "$DIR/quota-error.txt" || fail 'quota-error.txt не содержит понятной диагностики'
