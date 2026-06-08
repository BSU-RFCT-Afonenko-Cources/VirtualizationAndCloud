#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-metadata
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for file in selected-snapshot.txt snapshot-dump.xml snapshot-current.txt snapshot-info.txt snapshot-parent.txt; do /usr/bin/test -s "$DIR/$file" || fail "нет непустого файла $file"; done
NAME=$(/usr/bin/head -n 1 "$DIR/selected-snapshot.txt")
case "$NAME" in lab-*) ;; *) fail 'выбран snapshot без префикса lab-';; esac
/usr/bin/grep -q "<name>$NAME</name>" "$DIR/snapshot-dump.xml" || fail 'snapshot-dump.xml не соответствует выбранному имени'
/usr/bin/grep -q "$NAME" "$DIR/snapshot-info.txt" || fail 'snapshot-info.txt не содержит выбранное имя'
