#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/inspect-default-network
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in net-list.txt net-info-default.txt default.xml virbr0-addr.txt default-leases.txt; do
  /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"
done
/usr/bin/grep -q '<network' "$DIR/default.xml" || fail 'default.xml должен содержать элемент <network> или диагностическую XML-заглушку'
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info default >/home/ubuntu/inspect-default-network/lab-default-info 2>/dev/null; then
  /usr/bin/grep -Eq '^(Active|Активна):[[:space:]]+yes|^Active:[[:space:]]+yes|^Активна:[[:space:]]+да' /home/ubuntu/inspect-default-network/lab-default-info || fail 'сеть default есть, но не активна; запустите её или явно зафиксируйте диагностику'
  /usr/bin/grep -q '<name>default</name>' "$DIR/default.xml" || fail 'default.xml не похож на XML сети default'
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml default | /usr/bin/grep -q "<forward mode='nat'"; then
    /usr/bin/grep -q "<forward mode='nat'" "$DIR/default.xml" || fail "для NAT-сети default в XML должен быть <forward mode='nat'>"
  fi
else
  /usr/bin/grep -qi 'absent\|нет\|missing' "$DIR/net-info-default.txt" || fail 'если default отсутствует, net-info-default.txt должен содержать понятную диагностику'
fi
