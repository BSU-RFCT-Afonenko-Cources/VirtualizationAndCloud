#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/bridge-tap-diagnostics
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in bridges.txt bridge-link.txt domiflist.txt domifaddr.txt connectivity.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет непустого файла $DIR/$f"; done
/usr/bin/grep -Eq 'virbr10|virbr20' "$DIR/bridges.txt" || fail 'bridges.txt должен содержать virbr10 или virbr20'
/usr/bin/grep -Eq '52:54:00:aa:10:01|52:54:00:aa:20:01' "$DIR/domiflist.txt" || fail 'domiflist.txt должен содержать MAC тестовых интерфейсов'
/usr/bin/grep -Eq '52:54:00:aa:10:01|52:54:00:aa:20:01|would run|PING|bytes from' "$DIR/connectivity.txt" || fail 'connectivity.txt должен содержать результат или команду диагностики'
