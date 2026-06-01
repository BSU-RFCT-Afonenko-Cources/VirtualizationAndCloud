#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-volume-attach
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if /usr/bin/test -s "$DIR/domblklist-lab-vm.txt" && /usr/bin/grep -Eq '(^|[[:space:]])vdb([[:space:]]|$)' "$DIR/domblklist-lab-vm.txt"; then
  exit 0
fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist lab-vm >/var/tmp/lab-vm-blk 2>/dev/null && /usr/bin/grep -Eq '(^|[[:space:]])vdb([[:space:]]|$)' /var/tmp/lab-vm-blk; then
  exit 0
fi
XML=$DIR/lab-disk-volume-fragment.xml
/usr/bin/test -s "$XML" || fail "нет domblklist с vdb и нет lab-disk-volume-fragment.xml"
/usr/bin/python3 - "$XML" <<'PYCHECK' || exit 1
import sys, xml.etree.ElementTree as ET
r=ET.parse(sys.argv[1]).getroot(); s=r.find('source'); t=r.find('target')
if r.tag!='disk' or r.get('type')!='volume' or s is None or s.get('pool')!='lab-pool' or s.get('volume')!='lab-disk.qcow2' or t is None or t.get('dev')!='vdb':
    print('Ошибка: XML-фрагмент должен ссылаться на source pool=lab-pool volume=lab-disk.qcow2 и target vdb', file=sys.stderr); sys.exit(1)
PYCHECK
