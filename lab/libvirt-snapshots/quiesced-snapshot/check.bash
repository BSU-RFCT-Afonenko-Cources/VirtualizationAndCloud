#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/quiesced-snapshot
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/domfsinfo.txt" || fail 'нет domfsinfo.txt'
/usr/bin/test -s "$DIR/domblklist-after.txt" || fail 'нет domblklist-after.txt'
if /usr/bin/test -s "$DIR/quiesce-success.txt"; then
  /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-quiesce-001 >/dev/null 2>&1 || fail 'заявлен успех, но metadata lab-quiesce-001 отсутствует'
  /usr/bin/test -s "$DIR/lab-quiesce-001.xml" || fail 'при успехе нет dumpxml'
  exit 0
fi
/usr/bin/test -s "$DIR/quiesce-error.txt" || fail 'нужен quiesce-success.txt или quiesce-error.txt'
/usr/bin/grep -Eqi 'agent|guest|quies|freeze|unsupported|not supported|недоступ|не поддерж|inactive|domain is not running|ошиб' "$DIR/quiesce-error.txt" || fail 'quiesce-error.txt не объясняет причину отказа'
