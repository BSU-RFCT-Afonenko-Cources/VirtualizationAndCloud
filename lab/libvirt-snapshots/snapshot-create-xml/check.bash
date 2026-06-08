#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-create-xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/lab-xml-001.xml" || fail 'нет lab-xml-001.xml'
/usr/bin/test -s "$DIR/domblklist-after.txt" || fail 'нет domblklist-after.txt'
/usr/bin/python3 - "$DIR/lab-xml-001.xml" <<'PYXML'
import sys, xml.etree.ElementTree as ET
r=ET.parse(sys.argv[1]).getroot()
if r.findtext('name')!='lab-xml-001': raise SystemExit('Ошибка: неверное имя snapshot')
d=next((x for x in r.findall('./disks/disk') if x.get('name')=='vda'),None)
if d is None or d.get('snapshot')!='external': raise SystemExit('Ошибка: vda не external')
if d.find('source') is None or d.find('source').get('file')!='/tmp/libvirt-snapshots/lab-xml-001.qcow2': raise SystemExit('Ошибка: неверный source')
PYXML
if /usr/bin/test -s "$DIR/create-result.txt"; then
  /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-xml-001 >/dev/null 2>&1 || fail 'заявлен успех, но metadata lab-xml-001 отсутствует'
  /usr/bin/test -s "$DIR/lab-xml-001-dump.xml" || fail 'нет dumpxml успешного snapshot'
else
  /usr/bin/test -s "$DIR/create-error.txt" || fail 'нет create-result.txt или create-error.txt'
fi
