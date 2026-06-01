#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/nat-network-xml
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/bin/cat >"$DIR/lab-nat.xml" <<'XML'
<network>
  <name>lab-nat</name>
  <forward mode='nat'/>
  <bridge name='virbr10' stp='on' delay='0'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.100.100' end='192.168.100.200'/>
      <host mac='52:54:00:aa:10:01' name='lab-vm-nat' ip='192.168.100.10'/>
    </dhcp>
  </ip>
</network>
XML
/usr/bin/chown ubuntu:ubuntu "$DIR/lab-nat.xml"
