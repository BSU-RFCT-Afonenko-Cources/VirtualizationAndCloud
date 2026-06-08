#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/external-disk-snapshot
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-ext-001 >/dev/null 2>&1; then
  ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
  /usr/bin/test "$ACTIVE" != /tmp/libvirt-snapshots/lab-ext-001.qcow2
  /usr/bin/rm -f /tmp/libvirt-snapshots/lab-ext-001.qcow2
  /usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-ext-001 --description 'Crash-consistent external disk snapshot' --disk-only --atomic --diskspec vda,snapshot=external,file=/tmp/libvirt-snapshots/lab-ext-001.qcow2 >/dev/null
fi
/usr/bin/virsh -c qemu:///system snapshot-list lab-vm >"$DIR/snapshot-list.txt"
/usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-ext-001 >"$DIR/lab-ext-001.xml"
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
