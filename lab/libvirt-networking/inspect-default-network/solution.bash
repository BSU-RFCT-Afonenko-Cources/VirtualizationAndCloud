#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/inspect-default-network
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-list --all >"$DIR/net-list.txt"
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info default >"$DIR/net-info-default.txt" 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml default >"$DIR/default.xml"
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dhcp-leases default >"$DIR/default-leases.txt" 2>&1 || /usr/bin/printf 'no leases or default network is absent\n' >"$DIR/default-leases.txt"
else
  /usr/bin/printf 'default network is absent\n' >"$DIR/net-info-default.txt"
  /usr/bin/printf '<network><name>default-absent</name></network>\n' >"$DIR/default.xml"
  /usr/bin/printf 'no leases or default network is absent\n' >"$DIR/default-leases.txt"
fi
/usr/sbin/ip addr show virbr0 >"$DIR/virbr0-addr.txt" 2>&1 || /usr/bin/printf 'virbr0 is absent\n' >"$DIR/virbr0-addr.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
