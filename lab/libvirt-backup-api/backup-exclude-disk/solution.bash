#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-exclude-disk
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /tmp/libvirt-backups
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist "$VM" --details >"$DIR/domblklist.txt" 2>&1 || /usr/bin/printf 'domblklist failed\n' >"$DIR/domblklist.txt"
/usr/bin/cat >"$DIR/exclude-disk.xml" <<'XML'
<domainbackup mode='push'>
  <disks>
    <disk name='vda' backup='yes' type='file'>
      <driver type='qcow2'/>
      <target file='/tmp/libvirt-backups/lab-vm-vda-exclude-demo.qcow2'/>
    </disk>
    <disk name='vdb' backup='no'/>
  </disks>
</domainbackup>
XML
if /usr/bin/grep -Eq '(^|[[:space:]])vdb([[:space:]]|$)' "$DIR/domblklist.txt"; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-begin "$VM" "$DIR/exclude-disk.xml" >"$DIR/backup-begin.txt" 2>&1 || /usr/bin/printf 'backup-begin failed or unsupported\n' >>"$DIR/backup-begin.txt"
  /usr/bin/printf 'vdb present; backup attempted\n' >"$DIR/diagnostics.txt"
else
  /usr/bin/printf 'vdb is absent; template only\n' >"$DIR/diagnostics.txt"
fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR" /tmp/libvirt-backups
