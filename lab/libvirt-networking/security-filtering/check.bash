#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/security-filtering
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in before.xml after.xml; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
if /usr/bin/grep -q "isolated='yes'\|isolated=\"yes\"\|<filterref" "$DIR/after.xml"; then exit 0; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-private >/var/tmp/lab-private-security.xml 2>/dev/null || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm --config >/var/tmp/lab-vm-security.xml 2>/dev/null || true
/usr/bin/grep -q "isolated='yes'\|isolated=\"yes\"\|<filterref" /var/tmp/lab-private-security.xml /var/tmp/lab-vm-security.xml || fail "не найдено isolated='yes' или <filterref>"
