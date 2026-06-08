#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
need_file /home/ubuntu/capstone/12-scheduling/evidence.json
xml=$(virsh dumpxml cap-app --config); quota=$(/usr/bin/sed -n 's:.*<quota>\(-\{0,1\}[0-9]*\)</quota>.*:\1:p' <<<"$xml"); period=$(/usr/bin/sed -n 's:.*<period>\([0-9]*\)</period>.*:\1:p' <<<"$xml"); [[ -n "$quota" && "$quota" -gt 0 && -n "$period" && "$period" -gt 0 && "$quota" -le "$period" ]] || fail 'не найдена ограничивающая quota/period policy'
/usr/bin/curl -fsS --max-time 5 http://192.168.150.10:8080/health >/dev/null || fail 'API недоступен после нагрузки'
