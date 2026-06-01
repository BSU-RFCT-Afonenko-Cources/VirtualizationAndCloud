#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-preview-xml
XML=$DIR/generated-by-args.xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$XML" || fail "нет generated-by-args.xml"
/usr/bin/python3 - "$XML" <<'PYCHECK'
import sys, xml.etree.ElementTree as ET
r=ET.parse(sys.argv[1]).getroot()
if r.tag!='volume' or r.findtext('name')!='generated-by-args.qcow2' or r.find('target/format').get('type')!='qcow2':
    print('Ошибка: XML должен описывать volume generated-by-args.qcow2 format qcow2', file=sys.stderr); sys.exit(1)
PYCHECK
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool generated-by-args.qcow2 >/dev/null 2>&1; then fail "generated-by-args.qcow2 не должен быть создан"; fi
