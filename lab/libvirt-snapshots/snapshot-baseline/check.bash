#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-baseline
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in domstate.txt domblklist.txt domain.xml disk-info.txt baseline.env; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
/usr/bin/grep -q '<domain' "$DIR/domain.xml" || fail 'domain.xml не содержит <domain>'
/usr/bin/grep -qx 'DISK_TARGET=vda' "$DIR/baseline.env" || fail 'baseline.env не содержит DISK_TARGET=vda'
BASE=$(/usr/bin/sed -n 's/^BASE_DISK=//p' "$DIR/baseline.env")
/usr/bin/test -n "$BASE" || fail 'BASE_DISK не задан'
case "$BASE" in /*) ;; *) fail 'BASE_DISK должен быть абсолютным путём';; esac
/usr/bin/grep -Eq '(^|[[:space:]])vda([[:space:]]|$)' "$DIR/domblklist.txt" || fail 'domblklist.txt не содержит target vda'
/usr/bin/grep -q '<name>lab-vm</name>' "$DIR/domain.xml" || fail 'сохранён XML не домена lab-vm'
