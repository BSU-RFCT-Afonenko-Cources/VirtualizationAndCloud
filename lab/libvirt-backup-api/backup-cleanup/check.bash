#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-cleanup
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in cleanup.txt checkpoint-list.txt domain-list.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/test -e "$DIR/backup-files.txt" || fail 'нет backup-files.txt'
/usr/bin/grep -Eq 'lab-' "$DIR/checkpoint-list.txt" && fail 'checkpoint metadata с префиксом lab- не очищена' || true
/usr/bin/test ! -s "$DIR/backup-files.txt" || fail '/tmp/libvirt-backups должен быть пуст после cleanup'
/usr/bin/find /tmp/libvirt-backups -mindepth 1 -maxdepth 1 -print -quit | /usr/bin/grep -q . && fail 'в /tmp/libvirt-backups остались временные объекты' || true
