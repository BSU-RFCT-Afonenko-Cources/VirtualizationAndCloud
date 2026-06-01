#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-clone
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/vol-info-lab-disk-clone.txt" || fail "нет vol-info-lab-disk-clone.txt"
/usr/bin/test -s "$DIR/reflink-preview.xml" -o -s "$DIR/reflink-preview.err" || fail "сохраните reflink-preview.xml или reflink-preview.err"
/usr/bin/python3 - <<'PYCHECK'
import subprocess, xml.etree.ElementTree as ET, sys
xml=subprocess.check_output(['/usr/bin/sudo','-n','/usr/bin/virsh','-c','qemu:///system','vol-dumpxml','--pool','lab-pool','lab-disk-clone.qcow2'], text=True)
r=ET.fromstring(xml); fmt=r.find('target/format').get('type'); cap=int(r.findtext('capacity'))
if fmt!='qcow2' or cap < 250*1024*1024:
    print('Ошибка: clone должен быть qcow2 и иметь capacity исходного volume', file=sys.stderr); sys.exit(1)
PYCHECK
