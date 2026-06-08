#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/checkpoint-create
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in checkpoint-manual.xml checkpoint-list.txt checkpoint-tree.txt parent.txt result.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -q '<name>lab-manual-001</name>' "$DIR/checkpoint-manual.xml" || fail 'XML должен задавать lab-manual-001'
if /usr/bin/grep -q 'lab-manual-001' "$DIR/checkpoint-list.txt" || /usr/bin/grep -q 'lab-manual-001' "$DIR/checkpoint-dumpxml.xml" 2>/dev/null; then exit 0; fi
/usr/bin/grep -qi 'unsupported\|not supported\|failed\|error\|cannot\|absent' "$DIR/result.txt" "$DIR/checkpoint-create.txt" "$DIR/checkpoint-dumpxml.txt" 2>/dev/null || fail 'нет checkpoint lab-manual-001 и нет корректной диагностики'
