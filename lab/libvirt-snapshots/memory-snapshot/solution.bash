#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/memory-snapshot
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/rm -f "$DIR/memory-success.txt" "$DIR/memory-error.txt"
/usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-mem-001 --description 'External memory and disk snapshot' --memspec file=/home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.memory,snapshot=external --diskspec vda,snapshot=external,file=/home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.qcow2 --print-xml >"$DIR/lab-mem-001.xml"
if /usr/bin/virsh -c qemu:///system snapshot-info lab-vm lab-mem-001 >/dev/null 2>&1; then
  /usr/bin/printf 'lab-mem-001 already exists\n' >"$DIR/memory-success.txt"
  /usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-mem-001 >"$DIR/lab-mem-001-dump.xml"
else
  STATE=$(/usr/bin/virsh -c qemu:///system domstate lab-vm 2>&1 || true)
  NEED_KIB=$(/usr/bin/virsh -c qemu:///system dominfo lab-vm | /usr/bin/awk '/^Max memory:/{print $3; exit}')
  FREE_KIB=$(/usr/bin/df -Pk /home/ubuntu/memory-snapshot/libvirt-snapshots | /usr/bin/awk 'NR==2{print $4}')
  if ! /usr/bin/printf '%s\n' "$STATE" | /usr/bin/grep -Eqi 'running|работает'; then
    /usr/bin/printf 'memory snapshot unsupported: domain is not running\n' >"$DIR/memory-error.txt"
  elif /usr/bin/test -n "$NEED_KIB" && /usr/bin/test "$FREE_KIB" -lt "$((NEED_KIB + 262144))"; then
    /usr/bin/printf 'memory snapshot unsupported: insufficient free space\n' >"$DIR/memory-error.txt"
  else
    /usr/bin/rm -f /home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.memory /home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.qcow2
    if /usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-mem-001 --description 'External memory and disk snapshot' --atomic --memspec file=/home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.memory,snapshot=external --diskspec vda,snapshot=external,file=/home/ubuntu/memory-snapshot/libvirt-snapshots/lab-mem-001.qcow2 >"$DIR/memory-success.txt" 2>"$DIR/memory-error.txt"; then
      /usr/bin/rm -f "$DIR/memory-error.txt"
      /usr/bin/virsh -c qemu:///system snapshot-dumpxml lab-vm lab-mem-001 >"$DIR/lab-mem-001-dump.xml"
    else
      /usr/bin/rm -f "$DIR/memory-success.txt"
      /usr/bin/test -s "$DIR/memory-error.txt" || /usr/bin/printf 'memory snapshot unsupported by driver\n' >"$DIR/memory-error.txt"
    fi
  fi
fi
/usr/bin/virsh -c qemu:///system domblklist lab-vm --details >"$DIR/domblklist-after.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
