#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/vol-create-xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"

fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/install -d -m 0755 /tmp/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-refresh lab-pool >/dev/null 2>&1 || true

/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-delete --pool lab-pool lab-from-xml.qcow2 >/dev/null 2>&1 || true
/usr/bin/cat >"$DIR/lab-volume.xml" <<'XML'
<volume>
  <name>lab-from-xml.qcow2</name>
  <capacity unit='MiB'>192</capacity>
  <allocation unit='B'>0</allocation>
  <target>
    <format type='qcow2'/>
  </target>
</volume>
XML
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create lab-pool "$DIR/lab-volume.xml" --validate >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-from-xml.qcow2 >"$DIR/vol-info-lab-from-xml.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
