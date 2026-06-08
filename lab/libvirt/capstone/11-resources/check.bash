#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
need_file /home/ubuntu/capstone/11-resources/resources.json
check_res(){ local d="$1" cpu="$2" kib="$3"; xml=$(virsh dumpxml "$d" --config); gotcpu=$(/usr/bin/sed -n "s:.*<vcpu[^>]*>\([0-9]*\)</vcpu>.*:\1:p" <<<"$xml" | /usr/bin/head -1); gotmem=$(/usr/bin/sed -n "s:.*<memory unit='KiB'>\([0-9]*\)</memory>.*:\1:p" <<<"$xml" | /usr/bin/head -1); [[ "$gotcpu" == "$cpu" ]] || fail "$d: ожидалось $cpu vCPU"; [[ "$gotmem" == "$kib" ]] || fail "$d: неверная память ($gotmem KiB)"; }
check_res cap-edge 1 524288; check_res cap-app 2 1048576; check_res cap-db 2 1572864
/usr/bin/grep -q 'cap-db-data.qcow2' < <(virsh dumpxml cap-db --config) || fail 'db data disk не виден'
