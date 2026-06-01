#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-backing-overlay
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-overlay.xml xpath-backing-path.txt xpath-backing-format.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -qx 'qcow2' "$DIR/xpath-backing-format.txt" || fail "backing format должен быть qcow2"
/usr/bin/grep -q '/tmp/libvirt-lab-pool/lab-disk.qcow2' "$DIR/xpath-backing-path.txt" || fail "backing path должен указывать на lab-disk.qcow2"
/usr/bin/python3 - <<'PYCHECK'
import subprocess, xml.etree.ElementTree as ET, sys
xml=subprocess.check_output(['/usr/bin/sudo','-n','/usr/bin/virsh','-c','qemu:///system','vol-dumpxml','--pool','lab-pool','lab-overlay.qcow2'], text=True)
r=ET.fromstring(xml); bs=r.find('backingStore')
if bs is None or bs.findtext('path') is None or bs.find('format').get('type')!='qcow2':
    print('Ошибка: lab-overlay.qcow2 должен иметь backingStore format qcow2', file=sys.stderr); sys.exit(1)
PYCHECK
