#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-xml-full
TARGET=/home/ubuntu/backup-xml-full/libvirt-backups/lab-vm-vda-full.qcow2
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /home/ubuntu/backup-xml-full/libvirt-backups
/usr/bin/cat >"$DIR/full-backup.xml" <<'XML'
<domainbackup mode='push'>
  <disks>
    <disk name='vda' backup='yes' type='file'>
      <driver type='qcow2'/>
      <target file='/home/ubuntu/backup-xml-full/libvirt-backups/lab-vm-vda-full.qcow2'/>
    </disk>
  </disks>
</domainbackup>
XML
/usr/bin/rm -f "$TARGET"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-begin "$VM" "$DIR/full-backup.xml" >"$DIR/backup-begin.txt" 2>&1; then
  if /usr/bin/test -e "$TARGET"; then /usr/bin/printf 'created\n' >"$DIR/result.txt"; else /usr/bin/printf 'job-active-or-completed\n' >"$DIR/result.txt"; fi
else
  /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"
fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR" /home/ubuntu/backup-xml-full/libvirt-backups
