#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/backup-restore
BACKUPDIR=/home/ubuntu/backup-restore/libvirt-backups
SOURCE=$BACKUPDIR/lab-vm-vda-full.qcow2
RESTORE=$BACKUPDIR/lab-vm-restore.qcow2
DOMAINXML=$BACKUPDIR/lab-vm.xml
RESTOREXML=$DIR/lab-vm-restore.xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/install -d -m 0777 "$BACKUPDIR"
if /usr/bin/test -s "$SOURCE"; then
  /usr/bin/cp --reflink=auto "$SOURCE" "$RESTORE"
  /usr/bin/rm -f "$BACKUPDIR/lab-vm-restore.missing"
  /usr/bin/printf 'backup copied to restore path\n' >"$DIR/restore-status.txt"
else
  /usr/bin/rm -f "$RESTORE"
  /usr/bin/printf 'full backup is absent; restore disk not created\n' >"$BACKUPDIR/lab-vm-restore.missing"
  /usr/bin/printf 'skeleton XML only\n' >"$DIR/restore-status.txt"
fi
if ! /usr/bin/test -s "$DOMAINXML"; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm >"$DOMAINXML" 2>/dev/null || /usr/bin/printf '<domain type="qemu"><name>lab-vm</name><devices><disk type="file" device="disk"><target dev="vda" bus="virtio"/><source file="/home/ubuntu/backup-restore/libvirt-images/lab-vm.qcow2"/></disk></devices></domain>\n' >"$DOMAINXML"
fi
/usr/bin/python3 - "$DOMAINXML" "$RESTOREXML" <<'PYXML'
import sys
import xml.etree.ElementTree as ET
src, dst = sys.argv[1:]
root = ET.parse(src).getroot()
name = root.find('name')
if name is None:
    name = ET.SubElement(root, 'name')
name.text = 'lab-vm-restore'
for uuid in list(root.findall('uuid')):
    root.remove(uuid)
disk = None
for candidate in root.findall('./devices/disk'):
    target = candidate.find('target')
    if candidate.get('device', 'disk') == 'disk' and (target is None or target.get('dev') == 'vda'):
        disk = candidate
        break
if disk is None:
    devices = root.find('devices')
    if devices is None:
        devices = ET.SubElement(root, 'devices')
    disk = ET.SubElement(devices, 'disk', {'type': 'file', 'device': 'disk'})
    ET.SubElement(disk, 'target', {'dev': 'vda', 'bus': 'virtio'})
disk.set('type', 'file')
source = disk.find('source')
if source is None:
    source = ET.SubElement(disk, 'source')
source.attrib.clear()
source.set('file', '/home/ubuntu/backup-restore/libvirt-backups/lab-vm-restore.qcow2')
ET.indent(root, space='  ')
ET.ElementTree(root).write(dst, encoding='unicode', xml_declaration=False)
with open(dst, 'a', encoding='utf-8') as out:
    out.write('\n')
PYXML
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/original-domblklist.txt" 2>&1 || /usr/bin/printf 'lab-vm unavailable\n' >"$DIR/original-domblklist.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR" "$BACKUPDIR"
