#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-xml-full
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/full-backup.xml" || fail 'нет full-backup.xml'
/usr/bin/grep -q '<domainbackup' "$DIR/full-backup.xml" || fail 'root должен быть <domainbackup>'
/usr/bin/grep -q "mode='push'\|mode=\"push\"" "$DIR/full-backup.xml" || fail 'нужен mode push'
/usr/bin/grep -q "/tmp/libvirt-backups/lab-vm-vda-full.qcow2" "$DIR/full-backup.xml" || fail 'неверный target file'
/usr/bin/grep -q "type='qcow2'\|type=\"qcow2\"" "$DIR/full-backup.xml" || fail 'нужен qcow2 driver'
/usr/bin/test -s "$DIR/backup-begin.txt" || fail 'нужно сохранить backup-begin.txt'
/usr/bin/test -e /tmp/libvirt-backups/lab-vm-vda-full.qcow2 || /usr/bin/grep -qi 'unsupported\|job-active\|completed\|not supported\|failed\|error\|cannot' "$DIR/result.txt" "$DIR/backup-begin.txt" || fail 'нет backup-файла и нет корректной диагностики'
