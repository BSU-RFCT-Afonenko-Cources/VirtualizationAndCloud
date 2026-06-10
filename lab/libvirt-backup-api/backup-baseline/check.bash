#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-baseline
BACKUPDIR=/home/ubuntu/backup-baseline/libvirt-backups
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in "$DIR/domstate.txt" "$DIR/domblklist.txt" "$BACKUPDIR/lab-vm.xml"; do /usr/bin/test -s "$f" || fail "нет непустого файла $f"; done
/usr/bin/grep -q '<domain' "$BACKUPDIR/lab-vm.xml" || fail 'lab-vm.xml должен содержать XML домена'
/usr/bin/grep -Eq 'disk[[:space:]]+file|file[[:space:]]+disk|vda' "$DIR/domblklist.txt" || fail 'domblklist.txt должен содержать хотя бы один file-backed disk target, обычно vda'
