#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-pull-mode
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in pull-backup.xml backup-dumpxml.xml backup-begin.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -q "mode='pull'\|mode=\"pull\"" "$DIR/pull-backup.xml" || fail 'нужен mode pull'
/usr/bin/grep -q "transport='unix'\|transport=\"unix\"\|transport='tcp'\|transport=\"tcp\"" "$DIR/pull-backup.xml" || fail 'нужен NBD server transport'
/usr/bin/grep -q '/home/ubuntu/backup-pull-mode/libvirt-backups/lab-vm-backup.sock' "$DIR/pull-backup.xml" || fail 'неверный Unix socket'
/usr/bin/grep -q '<scratch' "$DIR/pull-backup.xml" || fail 'pull-mode disk должен задавать scratch storage'
