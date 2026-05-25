#!/bin/fish
cat > /home/ubuntu/network/isolated-net.xml <<'XML'
<network><name>isolated-lab</name><bridge name='virbr10'/><ip address='10.10.10.1' netmask='255.255.255.0'><dhcp><range start='10.10.10.100' end='10.10.10.200'/></dhcp></ip></network>
XML
virsh net-define /home/ubuntu/network/isolated-net.xml >/dev/null 2>/dev/null; or true
virsh net-start isolated-lab >/dev/null 2>/dev/null; or true
virsh net-autostart isolated-lab >/dev/null 2>/dev/null; or true
