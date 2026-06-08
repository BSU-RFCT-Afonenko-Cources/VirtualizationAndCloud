#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-metadata
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
NAME=''
for candidate in lab-xml-001 lab-mem-001 lab-quiesce-001 lab-ext-001; do if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm "$candidate" >/dev/null 2>&1; then NAME=$candidate; break; fi; done
if /usr/bin/test -z "$NAME"; then NAME=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name | /usr/bin/grep '^lab-' | /usr/bin/head -n 1); fi
/usr/bin/test -n "$NAME"
/usr/bin/printf '%s\n' "$NAME" >"$DIR/selected-snapshot.txt"
/usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm "$NAME" >"$DIR/snapshot-dump.xml"
/usr/bin/virsh -c qemu:///system snapshot-current lab-vm --name >"$DIR/snapshot-current.txt" 2>&1 || /usr/bin/printf 'no current snapshot marker\n' >"$DIR/snapshot-current.txt"
/usr/bin/virsh -c qemu:///system snapshot-info lab-vm "$NAME" >"$DIR/snapshot-info.txt"
/usr/bin/virsh -c qemu:///system snapshot-parent lab-vm "$NAME" >"$DIR/snapshot-parent.txt" 2>&1 || /usr/bin/printf 'snapshot %s has no parent or parent query is unsupported\n' "$NAME" >"$DIR/snapshot-parent.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
