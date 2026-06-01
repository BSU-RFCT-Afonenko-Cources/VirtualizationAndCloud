#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-create-xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/lab-volume.xml" || fail "нет lab-volume.xml"
/usr/bin/test -s "$DIR/vol-info-lab-from-xml.txt" || fail "нет vol-info-lab-from-xml.txt"
/usr/bin/python3 - <<'PYCHECK'
import subprocess, xml.etree.ElementTree as ET, sys
xml=subprocess.check_output(['/usr/bin/sudo','-n','/usr/bin/virsh','-c','qemu:///system','vol-dumpxml','--pool','lab-pool','lab-from-xml.qcow2'], text=True)
r=ET.fromstring(xml); cap=int(r.findtext('capacity')); fmt=r.find('target/format').get('type')
if fmt!='qcow2' or abs(cap-192*1024*1024)>1024*1024:
    print('Ошибка: lab-from-xml.qcow2 должен быть qcow2 capacity около 192M', file=sys.stderr); sys.exit(1)
PYCHECK
