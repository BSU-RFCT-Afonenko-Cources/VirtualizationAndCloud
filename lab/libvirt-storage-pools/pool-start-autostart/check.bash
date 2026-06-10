#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-start-autostart
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in pool-info-lab-pool.txt pool-list-autostart.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/home/ubuntu/pool-start-autostart/lab-pool-info-start 2>&1 || fail "lab-pool отсутствует"
/usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(running|active|актив)' /home/ubuntu/pool-start-autostart/lab-pool-info-start || fail "lab-pool должен быть active/running"
/usr/bin/grep -Eq '^(Autostart|Автозапуск):[[:space:]]+(yes|да)' /home/ubuntu/pool-start-autostart/lab-pool-info-start || fail "Autostart должен быть yes"
/usr/bin/grep -q 'lab-pool' "$DIR/pool-list-autostart.txt" || fail "pool-list --autostart должен содержать lab-pool"
