#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-dumpxml-xpath
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-pool.xml xpath-name.txt xpath-type.txt xpath-target-path.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/python3 - "$DIR/lab-pool.xml" <<'PYCHECK' || exit 1
import sys, xml.etree.ElementTree as ET
r=ET.parse(sys.argv[1]).getroot()
vals=(r.findtext('name'), r.get('type'), r.findtext('target/path'))
if vals != ('lab-pool','dir','/tmp/libvirt-lab-pool'):
    print(f'Ошибка: неверный XML pool: {vals}', file=sys.stderr); sys.exit(1)
PYCHECK
/usr/bin/test "$(/usr/bin/tr -d '\n\r ' <"$DIR/xpath-name.txt")" = lab-pool || fail "xpath-name.txt должен содержать lab-pool"
/usr/bin/test "$(/usr/bin/tr -d '\n\r ' <"$DIR/xpath-type.txt")" = dir || fail "xpath-type.txt должен содержать dir"
/usr/bin/test "$(/usr/bin/tr -d '\n\r ' <"$DIR/xpath-target-path.txt")" = /tmp/libvirt-lab-pool || fail "xpath-target-path.txt должен содержать /tmp/libvirt-lab-pool"
