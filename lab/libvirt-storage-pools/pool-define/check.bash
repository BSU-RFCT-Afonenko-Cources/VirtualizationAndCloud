#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-define
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in pool-list-all.txt pool-info-lab-pool.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $DIR/$f"; done
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/home/ubuntu/pool-define/lab-pool-info-define 2>&1 || fail "lab-pool не определён"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-dumpxml lab-pool >/home/ubuntu/pool-define/lab-pool-define.xml 2>&1 || fail "не удалось получить XML lab-pool"
/usr/bin/python3 - <<'PYCHECK' || exit 1
import xml.etree.ElementTree as ET, sys
r=ET.parse('/home/ubuntu/pool-define/lab-pool-define.xml').getroot()
if r.get('type')!='dir' or r.findtext('name')!='lab-pool' or r.findtext('target/path')!='/home/ubuntu/pool-define/libvirt-lab-pool':
    print('Ошибка: lab-pool должен быть dir pool с target /home/ubuntu/pool-define/libvirt-lab-pool', file=sys.stderr); sys.exit(1)
PYCHECK
/usr/bin/grep -Eq '^(State|Состояние):[[:space:]]+(inactive|running|active|неактив|актив)' /home/ubuntu/pool-define/lab-pool-info-define || fail "pool-info не содержит ожидаемого state"
