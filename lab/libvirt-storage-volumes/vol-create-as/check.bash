#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-create-as
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/vol-list-details.txt" || fail "нет vol-list-details.txt"
for f in "$DIR/vol-info-lab-disk.txt" "$DIR/vol-info-lab-sparse.txt" "$DIR/vol-info-lab-raw.txt"; do /usr/bin/test -s "$f" || fail "нет ${f}"; done
/usr/bin/python3 - <<'PYCHECK'
import subprocess, xml.etree.ElementTree as ET, sys
want={'lab-disk.qcow2':('qcow2',256*1024*1024),'lab-sparse.qcow2':('qcow2',1024*1024*1024),'lab-raw.img':('raw',128*1024*1024)}
for name,(fmt,cap) in want.items():
    xml=subprocess.check_output(['/usr/bin/sudo','-n','/usr/bin/virsh','-c','qemu:///system','vol-dumpxml','--pool','lab-pool',name], text=True)
    root=ET.fromstring(xml)
    gotfmt=root.find('target/format').get('type')
    gotcap=int(root.findtext('capacity'))
    if gotfmt != fmt or abs(gotcap-cap) > 1024*1024:
        print(f'Ошибка: {name}: ожидались format={fmt}, capacity≈{cap}, получены {gotfmt}, {gotcap}', file=sys.stderr); sys.exit(1)
PYCHECK
