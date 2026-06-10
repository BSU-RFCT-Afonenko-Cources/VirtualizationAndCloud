#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-xml-cleanup
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/cat >"$DIR/lab-pool-xml.xml" <<'XML'
<pool type='dir'>
  <name>lab-pool-xml</name>
  <target>
    <path>/home/ubuntu/pool-xml-cleanup/libvirt-lab-pool-xml</path>
  </target>
</pool>
XML
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool-xml >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define "$DIR/lab-pool-xml.xml" >/dev/null
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool-xml >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool-xml >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool-xml >"$DIR/pool-info-lab-pool-xml.txt"
for P in lab-pool lab-pool-xml; do
  if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info "$P" >/dev/null 2>&1; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-autostart "$P" --disable >/dev/null 2>&1 || true
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-destroy "$P" >/dev/null 2>&1 || true
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-undefine "$P" >/dev/null 2>&1 || true
  fi
done
/usr/bin/sudo -n /usr/bin/rm -rf /home/ubuntu/pool-xml-cleanup/libvirt-lab-pool /home/ubuntu/pool-xml-cleanup/libvirt-lab-pool-xml
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-list --all >"$DIR/pool-list-final.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
