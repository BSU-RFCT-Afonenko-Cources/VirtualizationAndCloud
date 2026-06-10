#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-checkpoint-full
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /home/ubuntu/backup-checkpoint-full/libvirt-backups
/usr/bin/cat >"$DIR/full-backup.xml" <<'XML'
<domainbackup mode='push'>
  <disks>
    <disk name='vda' backup='yes' type='file'>
      <driver type='qcow2'/>
      <target file='/home/ubuntu/backup-checkpoint-full/libvirt-backups/lab-vm-vda-checkpoint-full.qcow2'/>
    </disk>
  </disks>
</domainbackup>
XML
/usr/bin/cat >"$DIR/checkpoint-full.xml" <<'XML'
<domaincheckpoint>
  <name>lab-full-001</name>
</domaincheckpoint>
XML
/usr/bin/rm -f /home/ubuntu/backup-checkpoint-full/libvirt-backups/lab-vm-vda-checkpoint-full.qcow2
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-begin "$VM" "$DIR/full-backup.xml" "$DIR/checkpoint-full.xml" >"$DIR/backup-begin.txt" 2>&1; then /usr/bin/printf 'started-or-completed\n' >"$DIR/result.txt"; else /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" >"$DIR/checkpoint-list.txt" 2>&1 || /usr/bin/printf 'checkpoint-list unavailable\n' >"$DIR/checkpoint-list.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-dumpxml "$VM" lab-full-001 >"$DIR/checkpoint-dumpxml.xml" 2>"$DIR/checkpoint-dumpxml.txt" || /usr/bin/test -s "$DIR/checkpoint-dumpxml.txt" || /usr/bin/printf 'lab-full-001 absent or unsupported\n' >"$DIR/checkpoint-dumpxml.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR" /home/ubuntu/backup-checkpoint-full/libvirt-backups
