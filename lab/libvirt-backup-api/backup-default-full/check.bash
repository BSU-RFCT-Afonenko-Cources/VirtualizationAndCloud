#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-default-full
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/backup-begin.txt" || fail 'нет backup-begin.txt с выводом команды'
/usr/bin/test -s "$DIR/result.txt" || fail 'нет result.txt'
if /usr/bin/grep -q 'started-or-completed' "$DIR/result.txt"; then
  if /usr/bin/test -s "$DIR/backup-dumpxml.xml"; then /usr/bin/grep -q '<domainbackup' "$DIR/backup-dumpxml.xml" || fail 'backup-dumpxml.xml не содержит <domainbackup>'; else /usr/bin/test -s "$DIR/backup-dumpxml.txt" || fail 'нужно сохранить backup-dumpxml XML или диагностику'; fi
else
  /usr/bin/grep -qi 'unsupported\|not supported\|unknown\|failed\|error\|cannot\|not found\|unavailable\|не поддерж' "$DIR/backup-begin.txt" || fail 'unsupported должен сопровождаться понятной диагностикой backup-begin'
fi
