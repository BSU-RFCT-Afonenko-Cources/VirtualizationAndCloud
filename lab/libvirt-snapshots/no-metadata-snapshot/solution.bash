#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/no-metadata-snapshot
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name >"$DIR/snapshot-names-before.txt"
ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
if /usr/bin/test "$ACTIVE" = /tmp/libvirt-snapshots/lab-nometa-001.qcow2; then
  /usr/bin/printf 'lab-nometa-001 overlay already active\n' >"$DIR/no-metadata-result.txt"
else
  /usr/bin/rm -f /tmp/libvirt-snapshots/lab-nometa-001.qcow2
  /usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-nometa-001 --description 'No-metadata live backup overlay' --disk-only --atomic --no-metadata --diskspec vda,snapshot=external,file=/tmp/libvirt-snapshots/lab-nometa-001.qcow2 >"$DIR/no-metadata-result.txt"
fi
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm --name >"$DIR/snapshot-names-after.txt"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
