#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
DIR=/home/ubuntu/capstone/01-inventory
for f in domains.txt networks.txt pools.txt nodeinfo.txt capabilities.xml; do need_file "$DIR/$f"; done
/usr/bin/python3 -c 'import xml.etree.ElementTree as E; E.parse("/home/ubuntu/capstone/01-inventory/capabilities.xml")' || fail 'capabilities.xml не является XML'
/usr/bin/grep -Eq 'CPU model|Модель CPU|CPU\(s\)|Процессор' "$DIR/nodeinfo.txt" || fail 'nodeinfo.txt не похож на virsh nodeinfo'
