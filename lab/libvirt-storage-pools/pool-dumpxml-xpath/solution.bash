#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/pool-dumpxml-xpath
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
if ! /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-info lab-pool >/dev/null 2>&1; then
  /usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-define-as lab-pool dir --target /tmp/libvirt-lab-pool >/dev/null
fi
/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system pool-dumpxml lab-pool >"$DIR/lab-pool.xml"
/usr/bin/python3 - "$DIR/lab-pool.xml" "$DIR" <<'PYSOL'
import sys, xml.etree.ElementTree as ET, pathlib
r=ET.parse(sys.argv[1]).getroot(); d=pathlib.Path(sys.argv[2])
(d/'xpath-name.txt').write_text(r.findtext('name')+'\n')
(d/'xpath-type.txt').write_text(r.get('type')+'\n')
(d/'xpath-target-path.txt').write_text(r.findtext('target/path')+'\n')
PYSOL
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
