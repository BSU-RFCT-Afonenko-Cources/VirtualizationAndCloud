#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-revert
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in marker-before.txt snapshot-current.txt domstate.txt domblklist-after.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
if /usr/bin/test -s "$DIR/revert-success.txt"; then
  /usr/bin/grep -qx 'lab-ext-001' "$DIR/snapshot-current.txt" || fail 'после успешного revert current не lab-ext-001'
  exit 0
fi
/usr/bin/test -s "$DIR/revert-error.txt" || fail 'нужен revert-success.txt или revert-error.txt'
/usr/bin/grep -Eqi 'external|unsupported|not supported|revert|disk snapshot|не поддерж|ошиб|inactive|risk' "$DIR/revert-error.txt" || fail 'revert-error.txt не объясняет отказ'
