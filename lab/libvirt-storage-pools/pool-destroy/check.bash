#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-destroy
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in pool-info-after-destroy.txt pool-info-after-restart.txt vol-list-after-restart.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(inactive|неактив)' "$DIR/pool-info-after-destroy.txt" || fail "pool-info-after-destroy.txt должен фиксировать inactive state"
/usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(running|active|актив)' "$DIR/pool-info-after-restart.txt" || fail "pool-info-after-restart.txt должен фиксировать active state"
/usr/bin/grep -q 'lab-disk.qcow2' "$DIR/vol-list-after-restart.txt" || fail "после restart должен сохраниться lab-disk.qcow2"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/var/tmp/lab-pool-info-destroy 2>&1 || fail "lab-pool отсутствует после restart"
/usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(running|active|актив)' /var/tmp/lab-pool-info-destroy || fail "lab-pool должен быть active после повторного запуска"
