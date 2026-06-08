#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-quota
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/schedinfo-after.txt" || fail 'нет schedinfo-after.txt'
if /usr/bin/grep -Eq 'vcpu_period[[:space:]]*:[[:space:]]*100000' "$DIR/schedinfo-after.txt" && /usr/bin/grep -Eq 'vcpu_quota[[:space:]]*:[[:space:]]*50000' "$DIR/schedinfo-after.txt"; then exit 0; fi
/usr/bin/test -s "$DIR/domain.xml" || fail 'нет domain.xml'
/usr/bin/grep -Eq '<period>100000</period>|<quota>50000</quota>' "$DIR/domain.xml" || fail 'quota/period не найдены ни в schedinfo, ни в XML'
