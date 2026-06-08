#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
DIR=/home/ubuntu/capstone/03-storage; need_file "$DIR/pool.xml"; need_file "$DIR/volumes.txt"
info=$(virsh pool-info capstone-pool) || fail 'pool capstone-pool не существует'
/usr/bin/grep -Eq 'running|активен|работает' <<<"$info" || fail 'pool не активен'; /usr/bin/grep -Eq 'yes|да' <<<"$info" || fail 'pool не persistent/autostart'
xml=$(virsh pool-dumpxml capstone-pool); /usr/bin/grep -q "<pool type='dir'>" <<<"$xml" || fail 'pool должен быть directory-backed'
/usr/bin/grep -q '<path>/var/lib/libvirt/capstone</path>' <<<"$xml" || fail 'неверный target pool'
for v in cap-edge.qcow2 cap-app.qcow2 cap-db.qcow2 cap-db-data.qcow2; do virsh vol-info --pool capstone-pool "$v" >/dev/null || fail "нет volume $v"; done
