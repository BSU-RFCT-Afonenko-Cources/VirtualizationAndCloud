#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-delete
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --tree >"$DIR/snapshot-tree-before.txt" 2>&1 || /usr/bin/printf 'snapshot tree unavailable\n' >"$DIR/snapshot-tree-before.txt"
: >"$DIR/delete-results.txt"
/usr/bin/rm -f "$DIR/delete-error.txt"
COUNT=0
while /usr/bin/test "$COUNT" -lt 32; do
  NAME=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name --leaves 2>/dev/null | /usr/bin/grep '^lab-' | /usr/bin/head -n 1 || true)
  if /usr/bin/test -z "$NAME"; then NAME=$(/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name | /usr/bin/grep '^lab-' | /usr/bin/tail -n 1 || true); fi
  /usr/bin/test -n "$NAME" || break
  if /usr/bin/virsh -c qemu:///system snapshot-delete lab-vm "$NAME" --metadata >>"$DIR/delete-results.txt" 2>>"$DIR/delete-error.txt"; then :; else break; fi
  COUNT=$((COUNT+1))
done
/usr/bin/test -s "$DIR/delete-results.txt" || /usr/bin/printf 'no lab-* snapshot metadata required deletion\n' >"$DIR/delete-results.txt"
/usr/bin/test ! -e "$DIR/delete-error.txt" || /usr/bin/test -s "$DIR/delete-error.txt" || /usr/bin/rm -f "$DIR/delete-error.txt"
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --tree >"$DIR/snapshot-tree-after.txt" 2>&1 || /usr/bin/printf 'snapshot tree unavailable after deletion\n' >"$DIR/snapshot-tree-after.txt"
/usr/bin/test -s "$DIR/snapshot-tree-after.txt" || /usr/bin/printf 'no snapshots remain\n' >"$DIR/snapshot-tree-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
