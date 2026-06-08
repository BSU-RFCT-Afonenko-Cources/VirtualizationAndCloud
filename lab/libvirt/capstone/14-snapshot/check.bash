#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
virsh snapshot-info cap-app before-app-upgrade >/dev/null || fail 'snapshot before-app-upgrade не существует'; need_file /home/ubuntu/capstone/14-snapshot/version.json; need_file /home/ubuntu/capstone/14-snapshot/health.json
v=$(/usr/bin/curl -fsS http://192.168.150.10:8080/version); /usr/bin/python3 -c 'import json,sys; assert json.loads(sys.argv[1])["version"]=="2.0.0"' "$v" || fail 'версия не обновлена до 2.0.0'
