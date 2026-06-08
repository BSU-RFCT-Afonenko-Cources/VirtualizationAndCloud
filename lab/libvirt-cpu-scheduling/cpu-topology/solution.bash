#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/cpu-topology
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system nodeinfo > "$DIR/nodeinfo.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system capabilities > "$DIR/capabilities.xml"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpucount lab-vm > "$DIR/vcpucount.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system vcpuinfo lab-vm > "$DIR/vcpuinfo.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system cpu-stats lab-vm --total > "$DIR/cpu-stats-total.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
