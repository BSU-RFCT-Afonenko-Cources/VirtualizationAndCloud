#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cputune-xml
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/domain.xml" || fail 'нет domain.xml'
/usr/bin/test -s "$DIR/cputune-grep.txt" || fail 'нет cputune-grep.txt'
/usr/bin/grep -q '<cputune>' "$DIR/cputune-grep.txt" || fail 'cputune-grep.txt должен фиксировать <cputune>'
/usr/bin/grep -Eq '<vcpupin|<shares>|<period>|<quota>|<emulatorpin|<emulator_period>|<global_period' "$DIR/cputune-grep.txt" || /usr/bin/test -s "$DIR/unsupported-elements.txt" || fail 'нет ожидаемых cputune elements или unsupported-elements.txt'
