#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-default-full
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /tmp/libvirt-backups
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-begin "$VM" >"$DIR/backup-begin.txt" 2>&1; then
  /usr/bin/printf 'started-or-completed\n' >"$DIR/result.txt"
else
  /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"
fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-dumpxml "$VM" >"$DIR/backup-dumpxml.xml" 2>"$DIR/backup-dumpxml.txt"; then
  /usr/bin/rm -f "$DIR/backup-dumpxml.txt"
else
  /usr/bin/test -s "$DIR/backup-dumpxml.txt" || /usr/bin/printf 'backup XML is unavailable; job may have completed or API is unsupported\n' >"$DIR/backup-dumpxml.txt"
fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
