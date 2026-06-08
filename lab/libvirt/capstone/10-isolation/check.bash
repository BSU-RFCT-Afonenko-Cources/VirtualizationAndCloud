#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
F=/home/ubuntu/capstone/10-isolation/evidence.json; need_file "$F"
for d in cap-app cap-db; do xml=$(virsh dumpxml "$d" --config); ! /usr/bin/grep -q "network='cap-front'" <<<"$xml" || fail "$d не должен иметь frontend-интерфейс"; done
/usr/bin/python3 - "$F" <<'PY2'
import json
x=json.load(open('/home/ubuntu/capstone/10-isolation/evidence.json'))
assert x['entrypoint']=='http://192.168.150.10:8080'
assert x['nodes']['cap-app']['front'] is None and x['nodes']['cap-db']['front'] is None
assert x['edge_check']['status']==200 and x['app_db_check']['source']=='cap-db'
PY2
/usr/bin/curl -fsS --max-time 5 http://192.168.150.10:8080/orders >/dev/null || fail 'entrypoint не работает'
