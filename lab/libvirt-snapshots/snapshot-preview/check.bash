#!/usr/bin/env bash
set -euo pipefail
FILE=/home/ubuntu/snapshot-preview/lab-preview.xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$FILE" || fail 'нет lab-preview.xml'
/usr/bin/python3 - "$FILE" <<'PYXML'
import sys, xml.etree.ElementTree as ET
root=ET.parse(sys.argv[1]).getroot()
if root.tag!='domainsnapshot': raise SystemExit('Ошибка: root должен быть <domainsnapshot>')
if root.findtext('name')!='lab-preview': raise SystemExit('Ошибка: snapshot name должен быть lab-preview')
disk=next((d for d in root.findall('./disks/disk') if d.get('name')=='vda'),None)
if disk is None or disk.get('snapshot')!='external': raise SystemExit('Ошибка: vda должен иметь snapshot=external')
source=disk.find('source')
if source is None or source.get('file')!='/home/ubuntu/snapshot-preview/libvirt-snapshots/lab-preview.qcow2': raise SystemExit('Ошибка: неверный source preview overlay')
PYXML
/usr/bin/test ! -e /home/ubuntu/snapshot-preview/libvirt-snapshots/lab-preview.qcow2 || fail '--print-xml не должен создавать lab-preview.qcow2'
