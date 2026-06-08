#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-baseline
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -o root -g root -m 1777 /tmp/libvirt-snapshots
/usr/bin/virsh -c qemu:///system dominfo lab-vm >/dev/null
/usr/bin/virsh -c qemu:///system domstate lab-vm >"$DIR/domstate.txt"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist.txt"
/usr/bin/virsh -c qemu:///system dumpxml lab-vm >"$DIR/domain.xml"
BASE=$(/usr/bin/awk '$3=="vda"{print $4; exit}' "$DIR/domblklist.txt")
/usr/bin/test -n "$BASE"
/usr/bin/printf 'DISK_TARGET=vda\nBASE_DISK=%s\n' "$BASE" >"$DIR/baseline.env"
/usr/bin/qemu-img info "$BASE" >"$DIR/disk-info.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
