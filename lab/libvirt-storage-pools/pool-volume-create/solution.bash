#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-volume-create
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/pool-volume-create/libvirt-lab-pool >/dev/null; fi
/usr/bin/test -d /home/ubuntu/pool-volume-create/libvirt-lab-pool || /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool >/dev/null
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-start lab-pool >/dev/null 2>&1 || true
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-disk.qcow2 >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-create-as lab-pool lab-disk.qcow2 128M --format qcow2 >/dev/null
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-list lab-pool >"$DIR/vol-list.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-info --pool lab-pool lab-disk.qcow2 >"$DIR/vol-info-lab-disk.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-path --pool lab-pool lab-disk.qcow2 >"$DIR/vol-path-lab-disk.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vol-dumpxml --pool lab-pool lab-disk.qcow2 >"$DIR/vol-lab-disk.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
