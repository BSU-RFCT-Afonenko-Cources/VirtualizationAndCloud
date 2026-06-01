#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-preview-xml
XML=$DIR/lab-pool-preview.xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$XML" || fail "нет lab-pool-preview.xml"
/usr/bin/python3 - "$XML" <<'PYCHECK' || exit 1
import sys, xml.etree.ElementTree as ET
try:
    root=ET.parse(sys.argv[1]).getroot()
except Exception as e:
    print(f"Ошибка: XML не разбирается: {e}", file=sys.stderr); sys.exit(1)
for ok,msg in [(root.tag=='pool','root должен быть <pool>'),(root.get('type')=='dir','pool type должен быть dir'),(root.findtext('name')=='lab-pool','name должен быть lab-pool'),(root.findtext('target/path')=='/tmp/libvirt-lab-pool','target path должен быть /tmp/libvirt-lab-pool')]:
    if not ok:
        print('Ошибка: '+msg, file=sys.stderr); sys.exit(1)
PYCHECK
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  fail "pool lab-pool уже создан; на этом шаге нужен только --print-xml"
fi
