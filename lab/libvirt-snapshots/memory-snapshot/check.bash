#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/memory-snapshot
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$DIR/lab-mem-001.xml" || fail 'нет preview XML'
/usr/bin/test -s "$DIR/domblklist-after.txt" || fail 'нет domblklist-after.txt'
/usr/bin/grep -q '/tmp/libvirt-snapshots/lab-mem-001.memory' "$DIR/lab-mem-001.xml" || fail 'XML не содержит memory file'
/usr/bin/grep -q '/tmp/libvirt-snapshots/lab-mem-001.qcow2' "$DIR/lab-mem-001.xml" || fail 'XML не содержит external disk file'
if /usr/bin/test -s "$DIR/memory-success.txt"; then
  /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-mem-001 >/dev/null 2>&1 || fail 'заявлен успех, но metadata lab-mem-001 отсутствует'
  /usr/bin/test -s "$DIR/lab-mem-001-dump.xml" || fail 'нет dumpxml успешного memory snapshot'
  /usr/bin/test -s /tmp/libvirt-snapshots/lab-mem-001.memory || fail 'нет external memory file'
  exit 0
fi
/usr/bin/test -s "$DIR/memory-error.txt" || fail 'нужен memory-success.txt или memory-error.txt'
/usr/bin/grep -Eqi 'unsupported|not supported|memory|inactive|running|space|недостат|не поддерж|ошиб' "$DIR/memory-error.txt" || fail 'memory-error.txt не содержит понятной диагностики'
