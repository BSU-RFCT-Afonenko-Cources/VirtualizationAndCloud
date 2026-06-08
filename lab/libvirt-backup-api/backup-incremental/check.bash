#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-incremental
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in incremental-backup.xml checkpoint-inc.xml backup-begin.txt result.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -q '<incremental>lab-full-001</incremental>' "$DIR/incremental-backup.xml" || fail 'нужен incremental lab-full-001'
/usr/bin/grep -q '<name>lab-inc-001</name>' "$DIR/checkpoint-inc.xml" || fail 'нужен checkpoint lab-inc-001'
if /usr/bin/grep -q 'lab-inc-001' "$DIR/checkpoint-list-after.txt" 2>/dev/null; then exit 0; fi
/usr/bin/grep -qi 'unsupported\|absent\|not started\|not supported\|failed\|error\|cannot' "$DIR/result.txt" "$DIR/backup-begin.txt" || fail 'нет нового checkpoint и нет корректной диагностики'
