#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/schedinfo-read
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/schedinfo.txt" || fail 'нет schedinfo.txt'
/usr/bin/test -s "$DIR/domain.xml" || fail 'нет domain.xml'
/usr/bin/grep -Eiq 'Scheduler|cpu_shares|vcpu_period|vcpu_quota|emulator_|global_' "$DIR/schedinfo.txt" || fail 'schedinfo.txt не похож на вывод virsh schedinfo'
if /usr/bin/grep -q '<cputune>' "$DIR/domain.xml"; then
  /usr/bin/test -s "$DIR/cputune.xml" || fail 'в domain.xml есть cputune, но cputune.xml пуст'
  /usr/bin/grep -q '<cputune>' "$DIR/cputune.xml" || fail 'cputune.xml должен содержать <cputune>'
else
  /usr/bin/test -s "$DIR/cputune-absent.txt" || fail 'при отсутствии cputune нужен cputune-absent.txt'
fi
