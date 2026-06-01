#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-dumpxml-xpath
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
for f in lab-disk.xml xpath-name.txt xpath-capacity.txt xpath-format.txt xpath-path.txt; do /usr/bin/test -s "$DIR/$f" || fail "нет $f"; done
/usr/bin/grep -qx 'lab-disk.qcow2' "$DIR/xpath-name.txt" || fail "xpath-name.txt должен содержать lab-disk.qcow2"
/usr/bin/grep -qx 'qcow2' "$DIR/xpath-format.txt" || fail "xpath-format.txt должен содержать qcow2"
/usr/bin/grep -q '^/tmp/libvirt-lab-pool/' "$DIR/xpath-path.txt" || fail "xpath-path.txt должен указывать на /tmp/libvirt-lab-pool"
