#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
for f in health.json version.json orders.json; do need_file "/home/ubuntu/capstone/09-edge/$f"; done
headers=$(/usr/bin/curl -fsS -D - --max-time 5 http://192.168.150.10:8080/orders) || fail 'edge endpoint недоступен'; /usr/bin/grep -qi '^X-Cap-Edge: cap-edge' <<<"$headers" || fail 'нет заголовка reverse proxy'
/usr/bin/grep -q 'cap-app' <<<"$headers" && /usr/bin/grep -q 'cap-db' <<<"$headers" && /usr/bin/grep -q '1001' <<<"$headers" || fail 'ответ не подтверждает полную цепочку'
