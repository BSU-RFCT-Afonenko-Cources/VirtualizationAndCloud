#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/security-filtering
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-private >"$DIR/before.xml"
/usr/bin/python3 - <<'PY'
import subprocess, xml.etree.ElementTree as ET
xml = subprocess.check_output(['/usr/bin/sudo','-n','/usr/bin/virsh','-c','qemu:///system','net-dumpxml','lab-private'], text=True)
root = ET.fromstring(xml)
port = root.find('port')
if port is None:
    port = ET.SubElement(root, 'port')
port.set('isolated', 'yes')
ET.indent(root, space='  ')
ET.ElementTree(root).write('/var/tmp/lab-private-isolated.xml', encoding='unicode')
PY
if /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-info lab-private | /usr/bin/grep -Eq 'Active:[[:space:]]+yes|Активна:[[:space:]]+да|Активна:[[:space:]]+yes'; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-destroy lab-private
  active=1
else
  active=0
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-define /var/tmp/lab-private-isolated.xml
if /usr/bin/test "$active" = 1; then /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-start lab-private; fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system net-dumpxml lab-private >"$DIR/after.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
