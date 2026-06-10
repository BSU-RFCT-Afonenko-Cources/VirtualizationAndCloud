#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-restore
XML=$DIR/lab-vm-restore.xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in "$XML" "$DIR/restore-status.txt" "$DIR/original-domblklist.txt"; do /usr/bin/test -s "$f" || fail "нет непустого файла $f"; done
/usr/bin/grep -q '<name>lab-vm-restore</name>' "$XML" || fail 'restore XML должен иметь новое имя lab-vm-restore'
/usr/bin/grep -q '/home/ubuntu/backup-restore/libvirt-backups/lab-vm-restore.qcow2' "$XML" || fail 'restore XML должен ссылаться на отдельный restore disk'
/usr/bin/grep -q '<uuid>' "$XML" && fail 'исходный UUID должен быть удалён' || true
/usr/bin/grep -q '/home/ubuntu/backup-restore/libvirt-backups/lab-vm-restore.qcow2' "$DIR/original-domblklist.txt" && fail 'исходный lab-vm не должен использовать restore disk' || true
/usr/bin/test -s /home/ubuntu/backup-restore/libvirt-backups/lab-vm-restore.qcow2 || /usr/bin/test -s /home/ubuntu/backup-restore/libvirt-backups/lab-vm-restore.missing || fail 'нужен restore disk или marker отсутствующего full backup'
