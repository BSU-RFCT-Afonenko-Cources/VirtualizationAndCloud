#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-define
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /home/ubuntu/pool-define/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-list --all >"$DIR/pool-list-all.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >"$DIR/pool-info-lab-pool.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
