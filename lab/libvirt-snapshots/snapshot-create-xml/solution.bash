#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-create-xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/cat >"$DIR/lab-xml-001.xml" <<'XML'
<domainsnapshot>
  <name>lab-xml-001</name>
  <description>XML-first external disk-only snapshot</description>
  <memory snapshot='no'/>
  <disks>
    <disk name='vda' snapshot='external'>
      <driver type='qcow2'/>
      <source file='/tmp/libvirt-snapshots/lab-xml-001.qcow2'/>
    </disk>
  </disks>
</domainsnapshot>
XML
/usr/bin/rm -f "$DIR/create-result.txt" "$DIR/create-error.txt"
if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-xml-001 >/dev/null 2>&1; then
  /usr/bin/printf 'lab-xml-001 already exists\n' >"$DIR/create-result.txt"
else
  ACTIVE=$(/usr/bin/virsh -c qemu:///system domblklist lab-vm --details | /usr/bin/awk '$3=="vda"{print $4; exit}')
  if /usr/bin/test "$ACTIVE" != /tmp/libvirt-snapshots/lab-xml-001.qcow2; then /usr/bin/rm -f /tmp/libvirt-snapshots/lab-xml-001.qcow2; fi
  if /usr/bin/virsh -c qemu:///system snapshot-create lab-vm "$DIR/lab-xml-001.xml" --disk-only --atomic --validate >"$DIR/create-result.txt" 2>"$DIR/create-error.txt"; then
    /usr/bin/rm -f "$DIR/create-error.txt"
  elif /usr/bin/grep -Eqi 'validate|option' "$DIR/create-error.txt" && /usr/bin/virsh -c qemu:///system snapshot-create lab-vm "$DIR/lab-xml-001.xml" --disk-only --atomic >"$DIR/create-result.txt" 2>"$DIR/create-error.txt"; then
    /usr/bin/rm -f "$DIR/create-error.txt"
  else
    /usr/bin/rm -f "$DIR/create-result.txt"
    /usr/bin/test -s "$DIR/create-error.txt" || /usr/bin/printf 'snapshot-create failed\n' >"$DIR/create-error.txt"
  fi
fi
if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-xml-001 >/dev/null 2>&1; then /usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-xml-001 >"$DIR/lab-xml-001-dump.xml"; fi
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
