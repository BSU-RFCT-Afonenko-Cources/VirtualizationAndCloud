#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/isolated-network
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/bin/cat >"$DIR/lab-private.xml" <<'XML'
<network>
  <name>lab-private</name>
  <bridge name='virbr20' stp='on' delay='0'/>
  <ip address='10.20.0.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.20.0.100' end='10.20.0.200'/>
    </dhcp>
  </ip>
</network>
XML
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-define "$DIR/lab-private.xml"
fi
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private | /usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes'; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-start lab-private
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private >"$DIR/net-info-lab-private.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-private >"$DIR/lab-private-active.xml"
/usr/sbin/ip addr show virbr20 >"$DIR/virbr20-addr.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
