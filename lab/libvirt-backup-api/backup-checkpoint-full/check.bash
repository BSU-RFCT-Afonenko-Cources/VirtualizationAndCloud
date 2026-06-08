#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-checkpoint-full
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in full-backup.xml checkpoint-full.xml backup-begin.txt checkpoint-list.txt result.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -q '<name>lab-full-001</name>' "$DIR/checkpoint-full.xml" || fail 'checkpoint-full.xml должен задавать lab-full-001'
if /usr/bin/grep -q 'lab-full-001' "$DIR/checkpoint-list.txt" || /usr/bin/grep -q 'lab-full-001' "$DIR/checkpoint-dumpxml.xml" 2>/dev/null; then exit 0; fi
/usr/bin/grep -qi 'unsupported\|not supported\|failed\|error\|cannot\|absent' "$DIR/result.txt" "$DIR/backup-begin.txt" "$DIR/checkpoint-dumpxml.txt" 2>/dev/null || fail 'нет checkpoint lab-full-001 и нет корректной диагностики'
