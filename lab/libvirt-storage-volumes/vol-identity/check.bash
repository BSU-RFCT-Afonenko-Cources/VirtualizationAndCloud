#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-identity
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in vol-path.txt vol-key.txt vol-name-by-path.txt vol-pool-by-path.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -qx 'lab-disk.qcow2' "$DIR/vol-name-by-path.txt" || fail "vol-name-by-path.txt должен содержать lab-disk.qcow2"
/usr/bin/grep -qx 'lab-pool' "$DIR/vol-pool-by-path.txt" || fail "vol-pool-by-path.txt должен содержать lab-pool"
/usr/bin/grep -q '^/tmp/libvirt-lab-pool/lab-disk.qcow2$' "$DIR/vol-path.txt" || fail "vol-path.txt должен содержать path lab-disk.qcow2"
