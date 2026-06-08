#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
need_file /home/ubuntu/capstone/06-lifecycle/states.json
for d in cap-edge cap-app cap-db; do state=$(virsh domstate "$d"); /usr/bin/grep -Eq 'running|работает' <<<"$state" || fail "$d не запущен"; info=$(virsh dominfo "$d"); /usr/bin/grep -Eq 'Autostart:.*(enable|yes|да)|Автозапуск:.*(да|включ)' <<<"$info" || fail "$d без autostart"; done
/usr/bin/python3 -c 'import json;x=json.load(open("/home/ubuntu/capstone/06-lifecycle/states.json")); assert all(x[d]["ssh_ready"] for d in ("cap-edge","cap-app","cap-db"))' || fail 'states.json не подтверждает SSH'
