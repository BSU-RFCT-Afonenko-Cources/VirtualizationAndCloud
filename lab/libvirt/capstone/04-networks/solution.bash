#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Определяем frontend NAT-сеть и isolated backend-сеть со стабильными DHCP lease.
D=/home/ubuntu/capstone/04-networks; ensure_dir "$D"
/usr/bin/cat >/tmp/cap-front.xml <<'XML'
<network><name>cap-front</name><forward mode='nat'/><bridge name='virbr-cap-front' stp='on' delay='0'/><ip address='192.168.150.1' netmask='255.255.255.0'><dhcp><range start='192.168.150.100' end='192.168.150.200'/><host mac='52:54:00:ca:10:10' name='cap-edge' ip='192.168.150.10'/></dhcp></ip></network>
XML
/usr/bin/cat >/tmp/cap-back.xml <<'XML'
<network><name>cap-back</name><bridge name='virbr-cap-back' stp='on' delay='0'/><ip address='192.168.151.1' netmask='255.255.255.0'><dhcp><range start='192.168.151.100' end='192.168.151.200'/><host mac='52:54:00:ca:20:10' name='cap-edge-back' ip='192.168.151.10'/><host mac='52:54:00:ca:20:20' name='cap-app' ip='192.168.151.20'/><host mac='52:54:00:ca:20:30' name='cap-db' ip='192.168.151.30'/></dhcp></ip></network>
XML
for n in cap-front cap-back; do "${VIRSH[@]}" net-info "$n" >/dev/null 2>&1 || "${VIRSH[@]}" net-define "/tmp/$n.xml" >/dev/null; "${VIRSH[@]}" net-start "$n" >/dev/null 2>&1 || true; "${VIRSH[@]}" net-autostart "$n" >/dev/null; "${VIRSH[@]}" net-dumpxml "$n" >"$D/$n.xml"; done
/usr/bin/sudo -n /usr/bin/chown -R ubuntu:ubuntu "$D"
