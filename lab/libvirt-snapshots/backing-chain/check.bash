#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backing-chain
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in active-disk.env domblklist.txt backing-chain.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
ACTIVE=$(/usr/bin/sed -n 's/^ACTIVE_DISK=//p' "$DIR/active-disk.env")
BASE=$(/usr/bin/sed -n 's/^BASE_DISK=//p' /home/ubuntu/snapshot-baseline/baseline.env)
case "$ACTIVE" in /home/ubuntu/backing-chain/libvirt-snapshots/lab-*.qcow2) ;; *) fail 'active disk не является laboratory overlay';; esac
/usr/bin/grep -Fq "$ACTIVE" "$DIR/backing-chain.txt" || fail 'backing-chain.txt не содержит active overlay'
/usr/bin/grep -Fq "$BASE" "$DIR/backing-chain.txt" || fail 'backing-chain.txt не содержит исходный base'
