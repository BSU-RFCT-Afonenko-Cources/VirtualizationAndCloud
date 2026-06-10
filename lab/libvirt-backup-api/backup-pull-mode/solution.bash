#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-pull-mode
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /home/ubuntu/backup-pull-mode/libvirt-backups
/usr/bin/cat >"$DIR/pull-backup.xml" <<'XML'
<domainbackup mode='pull'>
  <server transport='unix' socket='/home/ubuntu/backup-pull-mode/libvirt-backups/lab-vm-backup.sock'/>
  <disks>
    <disk name='vda' backup='yes' type='file'>
      <driver type='qcow2'/>
      <scratch file='/home/ubuntu/backup-pull-mode/libvirt-backups/lab-vm-vda-pull-scratch.qcow2'/>
    </disk>
  </disks>
</domainbackup>
XML
/usr/bin/cp "$DIR/pull-backup.xml" "$DIR/backup-dumpxml.xml"
/usr/bin/printf 'template-only; NBD export not started without a client\n' >"$DIR/backup-begin.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
