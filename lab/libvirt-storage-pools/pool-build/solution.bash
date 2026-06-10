#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-build
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/pool-build/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-destroy lab-pool >/dev/null 2>&1 || true
/usr/bin/sudo -n /usr/bin/rm -rf /home/ubuntu/pool-build/libvirt-lab-pool
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-build lab-pool >/dev/null
/usr/bin/ls -ld /home/ubuntu/pool-build/libvirt-lab-pool >"$DIR/target-ls.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
