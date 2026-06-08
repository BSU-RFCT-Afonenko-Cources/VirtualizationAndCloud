#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-list
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in snapshot-list.txt snapshot-tree.txt snapshot-names.txt snapshot-internal.txt snapshot-external.txt snapshot-disk-only.txt; do /usr/bin/test -e "$DIR/$file" || fail "нет файла $file"; done
/usr/bin/test -s "$DIR/snapshot-list.txt" || fail 'snapshot-list.txt пуст'
/usr/bin/test -s "$DIR/snapshot-tree.txt" || fail 'snapshot-tree.txt пуст'
/usr/bin/grep -Eq 'Name|Имя|no snapshots|snapshot|Сним' "$DIR/snapshot-list.txt" "$DIR/snapshot-tree.txt" || fail 'нет вывода snapshot-list или понятной диагностики'
