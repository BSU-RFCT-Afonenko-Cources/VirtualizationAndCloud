#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-volume-create
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in vol-list.txt vol-info-lab-disk.txt vol-path-lab-disk.txt vol-lab-disk.xml; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-disk.qcow2 >/var/tmp/lab-disk-info 2>&1 || fail "volume lab-disk.qcow2 отсутствует"
PATH_NOW=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-path --pool lab-pool lab-disk.qcow2)
case "$PATH_NOW" in /tmp/libvirt-lab-pool/lab-disk.qcow2) ;; *) fail "vol-path должен быть внутри /tmp/libvirt-lab-pool";; esac
/usr/bin/python3 - "$DIR/vol-lab-disk.xml" <<'PYCHECK' || exit 1
import sys, xml.etree.ElementTree as ET
r=ET.parse(sys.argv[1]).getroot(); fmt=r.find('target/format')
if r.findtext('name')!='lab-disk.qcow2' or fmt is None or fmt.get('type')!='qcow2':
    print('Ошибка: vol XML должен описывать lab-disk.qcow2 формата qcow2', file=sys.stderr); sys.exit(1)
PYCHECK
