#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/interface-qos
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in domiftune-before.txt domiftune-after.txt lab-vm-config.xml; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domiftune lab-vm 52:54:00:aa:10:01 --config >/var/tmp/lab-domiftune 2>/dev/null || true
if /usr/bin/grep -Eq 'inbound.average[[:space:]]*:[[:space:]]*1024|outbound.average[[:space:]]*:[[:space:]]*1024|inbound_average[[:space:]]*=[[:space:]]*1024|outbound_average[[:space:]]*=[[:space:]]*1024' /var/tmp/lab-domiftune "$DIR/domiftune-after.txt"; then
  exit 0
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/var/tmp/lab-vm-qos.xml 2>/dev/null || fail 'домен lab-vm не определён'
/usr/bin/grep -A12 -B4 '52:54:00:aa:10:01' /var/tmp/lab-vm-qos.xml | /usr/bin/grep -q '<bandwidth>' || fail 'domiftune не показывает average=1024 и XML не содержит <bandwidth> для интерфейса'
