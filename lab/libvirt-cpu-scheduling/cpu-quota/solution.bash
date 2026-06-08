#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-quota
STATE_DIR=/home/ubuntu/.libvirt-cpu-scheduling
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -s "$STATE_DIR/baseline.env"; then . "$STATE_DIR/baseline.env"; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-before.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm --set vcpu_period=100000 --set vcpu_quota=50000 --live --config
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system schedinfo lab-vm > "$DIR/schedinfo-after.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system dumpxml lab-vm > "$DIR/domain.xml"

/usr/bin/chown -R ubuntu:ubuntu "$DIR"
