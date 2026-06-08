#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
F=/home/ubuntu/capstone/13-resize/evidence.json; need_file "$F"; cap=$(virsh vol-dumpxml --pool capstone-pool cap-db-data.qcow2 | /usr/bin/sed -n "s:.*<capacity unit='bytes'>\([0-9]*\)</capacity>.*:\1:p"); [[ "$cap" -ge 3221225472 ]] || fail 'volume меньше 3 GiB'
/usr/bin/python3 -c 'import json;x=json.load(open("/home/ubuntu/capstone/13-resize/evidence.json")); assert x["volume_capacity"]>=3221225472 and x["guest_device_bytes"]>=3221225472 and x["orders"]>=2' || fail 'evidence resize неполон'
/usr/bin/curl -fsS http://192.168.150.10:8080/orders | /usr/bin/grep -q '1001' || fail 'данные после resize недоступны'
