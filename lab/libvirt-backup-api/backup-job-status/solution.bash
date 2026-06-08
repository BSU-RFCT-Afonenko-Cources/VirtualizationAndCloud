#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-job-status
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-dumpxml "$VM" >"$DIR/backup-dumpxml.xml" 2>"$DIR/backup-dumpxml.txt"; then
  /usr/bin/rm -f "$DIR/backup-dumpxml.txt"
  /usr/bin/printf 'active\n' >"$DIR/status.txt"
else
  /usr/bin/test -s "$DIR/backup-dumpxml.txt" || /usr/bin/printf 'backup job is absent or unsupported\n' >"$DIR/backup-dumpxml.txt"
  /usr/bin/printf 'completed-or-absent\n' >"$DIR/status.txt"
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domjobinfo "$VM" >"$DIR/domjobinfo.txt" 2>&1 || /usr/bin/printf 'domjobinfo unavailable or no active job\n' >"$DIR/domjobinfo.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
