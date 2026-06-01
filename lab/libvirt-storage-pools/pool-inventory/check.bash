#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-inventory
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/env.sh" || fail "нет файла env.sh"
/usr/bin/grep -qx 'POOL_NAME=lab-pool' "$DIR/env.sh" || fail "env.sh должен содержать POOL_NAME=lab-pool"
/usr/bin/grep -qx 'POOL_DIR=/tmp/libvirt-lab-pool' "$DIR/env.sh" || fail "env.sh должен содержать POOL_DIR=/tmp/libvirt-lab-pool"
for f in pool-list-all.txt pool-list-details.txt pool-info-default.txt; do
  /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"
done
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/var/tmp/lab-pool-info-inventory 2>/dev/null; then
  if /usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(running|active|актив)' /var/tmp/lab-pool-info-inventory; then
    fail "lab-pool уже активен; очистите конфликтующий активный laboratory pool"
  fi
fi
