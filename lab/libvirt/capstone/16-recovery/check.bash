#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
F=/home/ubuntu/capstone/16-recovery/evidence.json; need_file "$F"
for d in cap-edge cap-app cap-db; do /usr/bin/grep -Eq 'running|работает' < <(virsh domstate "$d") || fail "$d не запущен"; done
body=$(/usr/bin/curl -fsS --max-time 5 http://192.168.150.10:8080/orders) || fail 'цепочка после recovery недоступна'; /usr/bin/grep -q '1001' <<<"$body" || fail 'контрольные данные потеряны'
/usr/bin/python3 -c 'import json;x=json.load(open("/home/ubuntu/capstone/16-recovery/evidence.json")); assert x["failure"] and x["recovery_source"] in ("snapshot","backup","saved-configuration") and x["endpoint_status"]==200 and x["orders_preserved"] and all(x["domains_running"].values())' || fail 'evidence recovery неполон'
