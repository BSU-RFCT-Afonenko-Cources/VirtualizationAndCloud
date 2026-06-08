#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-baseline
BACKUPDIR=/tmp/libvirt-backups
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 "$BACKUPDIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate "$VM" >"$DIR/domstate.txt" 2>&1 || /usr/bin/printf 'domain lab-vm is absent or unavailable\n' >"$DIR/domstate.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist "$VM" --details >"$DIR/domblklist.txt" 2>&1 || /usr/bin/printf 'domblklist failed for lab-vm\n' >"$DIR/domblklist.txt"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml "$VM" >"$BACKUPDIR/$VM.xml" 2>"$DIR/dumpxml.err"; then
  /usr/bin/rm -f "$DIR/dumpxml.err"
else
  /usr/bin/printf '<domain type="qemu"><name>lab-vm-unavailable</name></domain>\n' >"$BACKUPDIR/$VM.xml"
fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR" "$BACKUPDIR"
