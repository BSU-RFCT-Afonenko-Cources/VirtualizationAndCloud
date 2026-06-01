#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-preview-xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-destroy lab-pool >/dev/null 2>&1 || true
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-undefine lab-pool >/dev/null 2>&1 || true
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool --print-xml >"$DIR/lab-pool-preview.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
