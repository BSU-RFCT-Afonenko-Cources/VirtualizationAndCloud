#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-inventory
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/printf 'POOL_NAME=lab-pool\nPOOL_DIR=/home/ubuntu/pool-inventory/libvirt-lab-pool\n' >"$DIR/env.sh"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-list --all >"$DIR/pool-list-all.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-list --all --details >"$DIR/pool-list-details.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info default >"$DIR/pool-info-default.txt" 2>&1 || /usr/bin/printf 'default pool is absent\n' >"$DIR/pool-info-default.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
