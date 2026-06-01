#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-volume-attach
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool >/dev/null; fi
/usr/bin/test -d /tmp/libvirt-lab-pool || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-disk.qcow2 >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool lab-disk.qcow2 128M --format qcow2 >/dev/null; fi
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dominfo lab-vm >/dev/null 2>&1 && /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domstate lab-vm | /usr/bin/grep -qi running; then
  VOL_PATH=$(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-path --pool lab-pool lab-disk.qcow2)
  if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist lab-vm | /usr/bin/grep -Eq '(^|[[:space:]])vdb([[:space:]]|$)'; then
    /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system attach-disk lab-vm "$VOL_PATH" vdb --driver qemu --subdriver qcow2 --targetbus virtio --live --config >/dev/null
  fi
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system domblklist lab-vm >"$DIR/domblklist-lab-vm.txt"
else
  /usr/bin/cat >"$DIR/lab-disk-volume-fragment.xml" <<'XML'
<disk type='volume' device='disk'>
  <driver name='qemu' type='qcow2'/>
  <source pool='lab-pool' volume='lab-disk.qcow2'/>
  <target dev='vdb' bus='virtio'/>
</disk>
XML
fi
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
