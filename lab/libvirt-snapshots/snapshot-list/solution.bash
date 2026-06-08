#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-list
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
run(){ OUT=$1; shift; if ! /usr/bin/virsh -c qemu:///system "$@" >"$DIR/$OUT" 2>&1; then /usr/bin/test -s "$DIR/$OUT" || /usr/bin/printf 'command unsupported or failed\n' >"$DIR/$OUT"; fi; /usr/bin/test -s "$DIR/$OUT" || /usr/bin/printf 'no snapshots matched this view\n' >"$DIR/$OUT"; }
run snapshot-list.txt snapshot-list lab-vm
run snapshot-tree.txt snapshot-list lab-vm --tree
run snapshot-names.txt snapshot-list lab-vm --name
run snapshot-internal.txt snapshot-list lab-vm --internal
run snapshot-external.txt snapshot-list lab-vm --external
run snapshot-disk-only.txt snapshot-list lab-vm --disk-only
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
