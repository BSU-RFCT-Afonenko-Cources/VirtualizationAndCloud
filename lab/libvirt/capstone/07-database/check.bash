#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
dbxml=$(virsh dumpxml cap-db --config); /usr/bin/grep -q 'cap-db-data.qcow2' <<<"$dbxml" || fail 'data volume не подключён'
need_file /home/ubuntu/capstone/07-database/evidence.json
body=$(/usr/bin/curl -fsS --max-time 5 http://192.168.151.30:54321/orders) || fail 'database service недоступен'
/usr/bin/python3 -c 'import json,sys;x=json.loads(sys.argv[1]); assert x["source"]=="cap-db" and len(x["orders"])>=2 and any(o["id"]==1001 for o in x["orders"])' "$body" || fail 'database service не вернул контрольные данные'
