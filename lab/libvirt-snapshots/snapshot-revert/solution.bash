#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-revert
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/printf 'marker created before attempted revert to lab-ext-001\n' >"$DIR/marker-before.txt"
/usr/bin/rm -f "$DIR/revert-success.txt" "$DIR/revert-error.txt"
if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-ext-001 >/dev/null 2>&1; then
  if /usr/bin/virsh -c qemu:///system snapshot-revert lab-vm lab-ext-001 >"$DIR/revert-success.txt" 2>"$DIR/revert-error.txt"; then /usr/bin/rm -f "$DIR/revert-error.txt"; else /usr/bin/rm -f "$DIR/revert-success.txt"; /usr/bin/test -s "$DIR/revert-error.txt" || /usr/bin/printf 'external snapshot revert unsupported\n' >"$DIR/revert-error.txt"; fi
else
  /usr/bin/printf 'revert unavailable: lab-ext-001 metadata is absent\n' >"$DIR/revert-error.txt"
fi
/usr/bin/virsh -c qemu:///system snapshot-current lab-vm --name >"$DIR/snapshot-current.txt" 2>&1 || /usr/bin/printf 'no current snapshot marker after revert attempt\n' >"$DIR/snapshot-current.txt"
/usr/bin/virsh -c qemu:///system domstate lab-vm >"$DIR/domstate.txt"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
