#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-job-status
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/domjobinfo.txt" || fail 'нет domjobinfo.txt'
/usr/bin/test -s "$DIR/status.txt" || fail 'нет status.txt'
if /usr/bin/test -s "$DIR/backup-dumpxml.xml"; then /usr/bin/grep -q '<domainbackup' "$DIR/backup-dumpxml.xml" || fail 'backup-dumpxml.xml не содержит <domainbackup>'; else /usr/bin/test -s "$DIR/backup-dumpxml.txt" || fail 'нужен backup-dumpxml.xml или backup-dumpxml.txt'; fi
/usr/bin/grep -Eq 'active|completed-or-absent|unsupported' "$DIR/status.txt" || fail 'status.txt должен содержать active, completed-or-absent или unsupported'
