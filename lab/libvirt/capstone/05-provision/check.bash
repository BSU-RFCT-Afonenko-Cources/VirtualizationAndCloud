#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
for d in cap-edge cap-app cap-db; do virsh dominfo "$d" >/dev/null || fail "нет домена $d"; need_file "/home/ubuntu/capstone/05-provision/$d.xml"; done
edge=$(virsh dumpxml cap-edge --config); app=$(virsh dumpxml cap-app --config); db=$(virsh dumpxml cap-db --config)
/usr/bin/grep -q "network='cap-front'" <<<"$edge" && /usr/bin/grep -q "network='cap-back'" <<<"$edge" || fail 'edge должен иметь две сети'
/usr/bin/grep -q "network='cap-back'" <<<"$app" || fail 'app не подключён к backend'; ! /usr/bin/grep -q "network='cap-front'" <<<"$app" || fail 'app ошибочно подключён к frontend'
/usr/bin/grep -q 'cap-db-data.qcow2' <<<"$db" || fail 'data volume не подключён к db'
