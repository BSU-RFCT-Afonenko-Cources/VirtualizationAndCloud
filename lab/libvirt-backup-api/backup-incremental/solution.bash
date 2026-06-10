#!/usr/bin/env bash
set -euo pipefail
VM=lab-vm
DIR=/home/ubuntu/backup-incremental
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 /home/ubuntu/backup-incremental/libvirt-backups
/usr/bin/cat >"$DIR/incremental-backup.xml" <<'XML'
<domainbackup mode='push'>
  <incremental>lab-full-001</incremental>
  <disks>
    <disk name='vda' backup='yes' type='file'>
      <driver type='qcow2'/>
      <target file='/home/ubuntu/backup-incremental/libvirt-backups/lab-vm-vda-inc-001.qcow2'/>
    </disk>
  </disks>
</domainbackup>
XML
/usr/bin/cat >"$DIR/checkpoint-inc.xml" <<'XML'
<domaincheckpoint>
  <name>lab-inc-001</name>
</domaincheckpoint>
XML
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" >"$DIR/checkpoint-list.txt" 2>&1 || /usr/bin/printf 'checkpoint-list unavailable\n' >"$DIR/checkpoint-list.txt"
if /usr/bin/grep -q 'lab-full-001' "$DIR/checkpoint-list.txt"; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system backup-begin "$VM" "$DIR/incremental-backup.xml" "$DIR/checkpoint-inc.xml" >"$DIR/backup-begin.txt" 2>&1 && /usr/bin/printf 'started-or-completed\n' >"$DIR/result.txt" || /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"
else
  /usr/bin/printf 'base checkpoint lab-full-001 is absent; not started\n' >"$DIR/backup-begin.txt"
  /usr/bin/printf 'unsupported\n' >"$DIR/result.txt"
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system checkpoint-list "$VM" >"$DIR/checkpoint-list-after.txt" 2>&1 || /usr/bin/printf 'checkpoint-list unavailable\n' >"$DIR/checkpoint-list-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR" /home/ubuntu/backup-incremental/libvirt-backups
