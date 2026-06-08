#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
for f in health.json version.json orders.json service.log; do need_file "/home/ubuntu/capstone/08-api/$f"; done
h=$(/usr/bin/curl -fsS --max-time 5 http://192.168.151.20:8000/health) || fail 'API health недоступен'; v=$(/usr/bin/curl -fsS http://192.168.151.20:8000/version); o=$(/usr/bin/curl -fsS http://192.168.151.20:8000/orders)
/usr/bin/python3 -c 'import json,sys; h,v,o=map(json.loads,sys.argv[1:]); assert h["database"]=="ok" and v["version"] in ("1.0.0","2.0.0") and o["source"]=="cap-db" and o["via"]=="cap-db"' "$h" "$v" "$o" || fail 'API не подтверждает обращение к базе'
