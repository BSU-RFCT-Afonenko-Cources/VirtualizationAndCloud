#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/quiesced-snapshot
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/rm -f "$DIR/quiesce-success.txt" "$DIR/quiesce-error.txt"
/usr/bin/virsh -c qemu:///system domfsinfo lab-vm >"$DIR/domfsinfo.txt" 2>&1 || /usr/bin/printf 'guest agent unavailable for domfsinfo\n' >>"$DIR/domfsinfo.txt"
if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-quiesce-001 >/dev/null 2>&1; then
  /usr/bin/printf 'lab-quiesce-001 already exists\n' >"$DIR/quiesce-success.txt"
  /usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-quiesce-001 >"$DIR/lab-quiesce-001.xml"
else
  ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
  if /usr/bin/test "$ACTIVE" != /tmp/libvirt-snapshots/lab-quiesce-001.qcow2; then /usr/bin/rm -f /tmp/libvirt-snapshots/lab-quiesce-001.qcow2; fi
  if /usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-quiesce-001 --description 'Quiesced external snapshot' --disk-only --quiesce --atomic --diskspec vda,snapshot=external,file=/tmp/libvirt-snapshots/lab-quiesce-001.qcow2 >"$DIR/quiesce-success.txt" 2>"$DIR/quiesce-error.txt"; then
    /usr/bin/rm -f "$DIR/quiesce-error.txt"
    /usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-quiesce-001 >"$DIR/lab-quiesce-001.xml"
  else
    /usr/bin/rm -f "$DIR/quiesce-success.txt"
    /usr/bin/test -s "$DIR/quiesce-error.txt" || /usr/bin/printf 'quiesce operation failed\n' >"$DIR/quiesce-error.txt"
  fi
fi
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
