#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-exclude-disk
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/exclude-disk.xml" || fail 'нет exclude-disk.xml'
/usr/bin/grep -q "name='vda'\|name=\"vda\"" "$DIR/exclude-disk.xml" || fail 'XML должен содержать vda'
/usr/bin/grep -q "backup='yes'\|backup=\"yes\"" "$DIR/exclude-disk.xml" || fail 'vda должен быть backup=yes'
/usr/bin/grep -q "name='vdb'\|name=\"vdb\"" "$DIR/exclude-disk.xml" || fail 'XML должен явно упоминать vdb'
/usr/bin/grep -q "backup='no'\|backup=\"no\"" "$DIR/exclude-disk.xml" || fail 'vdb должен быть backup=no'
/usr/bin/test -s "$DIR/diagnostics.txt" || /usr/bin/test -s "$DIR/backup-begin.txt" || fail 'нужна диагностика наличия/отсутствия второго диска'
