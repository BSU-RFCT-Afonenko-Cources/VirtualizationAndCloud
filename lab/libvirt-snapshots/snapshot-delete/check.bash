#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-delete
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in snapshot-tree-before.txt snapshot-tree-after.txt delete-results.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
LEFT=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name | /usr/bin/grep '^lab-' || true)
if /usr/bin/test -n "$LEFT"; then
  /usr/bin/test -s "$DIR/delete-error.txt" || fail 'остались lab-* metadata без delete-error.txt'
  /usr/bin/grep -Eqi 'active|child|external|unsupported|metadata|не поддерж|ошиб' "$DIR/delete-error.txt" || fail 'delete-error.txt не объясняет оставшиеся metadata'
fi
