#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-xml-cleanup
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-pool-xml.xml pool-info-lab-pool-xml.txt pool-list-final.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then fail "lab-pool всё ещё определён"; fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool-xml >/dev/null 2>&1; then fail "lab-pool-xml всё ещё определён"; fi
/usr/bin/test ! -e /home/ubuntu/pool-xml-cleanup/libvirt-lab-pool || fail "/home/ubuntu/pool-xml-cleanup/libvirt-lab-pool не удалён"
/usr/bin/test ! -e /home/ubuntu/pool-xml-cleanup/libvirt-lab-pool-xml || fail "/home/ubuntu/pool-xml-cleanup/libvirt-lab-pool-xml не удалён"
if /usr/bin/grep -Eq '(^|[[:space:]])lab-pool([[:space:]]|$)|(^|[[:space:]])lab-pool-xml([[:space:]]|$)' "$DIR/pool-list-final.txt"; then fail "pool-list-final.txt не должен содержать lab-pool или lab-pool-xml"; fi
