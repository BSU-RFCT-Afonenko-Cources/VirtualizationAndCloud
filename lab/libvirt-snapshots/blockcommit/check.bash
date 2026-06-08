#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/blockcommit
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in active-before.txt domblklist-after.txt backing-chain-after.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
/usr/bin/test -e "$DIR/backing-before.txt" || fail 'нет файла backing-before.txt'
if /usr/bin/test -s "$DIR/blockcommit-output.txt"; then
  BEFORE=$(/usr/bin/head -n 1 "$DIR/active-before.txt")
  AFTER=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
  BACKING=$(/usr/bin/head -n 1 "$DIR/backing-before.txt")
  /usr/bin/test -n "$BACKING" || fail 'до успешного commit не сохранён backing path'
  /usr/bin/test "$AFTER" = "$BACKING" || fail "после pivot active source $AFTER не равен прежнему backing $BACKING"
  exit 0
fi
/usr/bin/test -s "$DIR/blockcommit-error.txt" || fail 'нужен blockcommit-output.txt или blockcommit-error.txt'
/usr/bin/grep -Eqi 'unsupported|not supported|inactive|backing|block|job|не поддерж|ошиб|no backing' "$DIR/blockcommit-error.txt" || fail 'blockcommit-error.txt не содержит понятной диагностики'
