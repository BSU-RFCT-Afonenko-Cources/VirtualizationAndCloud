#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/emulatorpin
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
fail(){ /usr/bin/printf 'Ошибка: %s
' "$1" >&2; exit 1; }
/usr/bin/test -d "$DIR" || fail "нет каталога $DIR"
/usr/bin/test -s "$DIR/domain.xml" || fail 'нет domain.xml'
if /usr/bin/grep -q '<emulatorpin' "$DIR/domain.xml"; then
  /usr/bin/grep -q '<emulatorpin' "$DIR/cputune.xml" || fail 'cputune.xml должен содержать emulatorpin'
else
  /usr/bin/test -s "$DIR/emulatorpin-error.txt" || fail 'нет emulatorpin в XML и нет диагностического emulatorpin-error.txt'
  /usr/bin/grep -Eiq 'unsupported|not supported|error|ошиб|не поддерж' "$DIR/emulatorpin-error.txt" || fail 'emulatorpin-error.txt не содержит понятной диагностики'
fi
