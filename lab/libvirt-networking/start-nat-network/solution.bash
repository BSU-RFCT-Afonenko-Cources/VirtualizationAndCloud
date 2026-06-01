#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/start-nat-network
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if /usr/bin/test -f /home/ubuntu/nat-network-xml/lab-nat.xml; then
  /bin/cp /home/ubuntu/nat-network-xml/lab-nat.xml "$DIR/lab-nat.xml"
else
  /bin/cat >"$DIR/lab-nat.xml" <<'XML'
<network><name>lab-nat</name><forward mode='nat'/><bridge name='virbr10' stp='on' delay='0'/><ip address='192.168.100.1' netmask='255.255.255.0'><dhcp><range start='192.168.100.100' end='192.168.100.200'/><host mac='52:54:00:aa:10:01' name='lab-vm-nat' ip='192.168.100.10'/></dhcp></ip></network>
XML
fi
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-nat >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-define "$DIR/lab-nat.xml"
fi
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-nat | /usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes'; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-start lab-nat
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-autostart lab-nat
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-list --all >"$DIR/net-list.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-nat >"$DIR/net-info-lab-nat.txt"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-nat >"$DIR/lab-nat-active.xml"
/usr/sbin/ip link show virbr10 >"$DIR/virbr10-link.txt"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
