#!/usr/bin/env bash
set -euo pipefail
XML=/home/ubuntu/nat-network-xml/lab-nat.xml
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
/usr/bin/test -s "$XML" || fail "нет файла $XML"
if /usr/bin/command -v /usr/bin/xmllint >/dev/null 2>&1; then
  /usr/bin/xmllint --noout "$XML" >/dev/null 2>&1 || fail 'XML не проходит xmllint --noout'
  name=$(/usr/bin/xmllint --xpath 'string(/network/name)' "$XML")
  forward=$(/usr/bin/xmllint --xpath 'string(/network/forward/@mode)' "$XML")
  bridge=$(/usr/bin/xmllint --xpath 'string(/network/bridge/@name)' "$XML")
  start=$(/usr/bin/xmllint --xpath 'string(/network/ip/dhcp/range/@start)' "$XML")
  end=$(/usr/bin/xmllint --xpath 'string(/network/ip/dhcp/range/@end)' "$XML")
  host=$(/usr/bin/xmllint --xpath "string(/network/ip/dhcp/host[@mac='52:54:00:aa:10:01']/@ip)" "$XML")
else
  /usr/bin/python3 - <<'PY' "$XML" >/home/ubuntu/nat-network-xml/lab-nat-xml-values
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
print(root.findtext('name') or '')
f = root.find('forward')
b = root.find('bridge')
print(f.get('mode','') if f is not None else '')
print(b.get('name','') if b is not None else '')
r = root.find('ip/dhcp/range')
print(r.get('start','') if r is not None else '')
print(r.get('end','') if r is not None else '')
print(next((h.get('ip','') for h in root.findall('ip/dhcp/host') if h.get('mac') == '52:54:00:aa:10:01'), ''))
PY
  name=$(/usr/bin/sed -n '1p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
  forward=$(/usr/bin/sed -n '2p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
  bridge=$(/usr/bin/sed -n '3p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
  start=$(/usr/bin/sed -n '4p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
  end=$(/usr/bin/sed -n '5p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
  host=$(/usr/bin/sed -n '6p' /home/ubuntu/nat-network-xml/lab-nat-xml-values)
fi
/usr/bin/test "$name" = lab-nat || fail 'name должен быть lab-nat'
/usr/bin/test "$forward" = nat || fail 'forward mode должен быть nat'
/usr/bin/test "$bridge" = virbr10 || fail 'bridge name должен быть virbr10'
/usr/bin/test "$start" = 192.168.100.100 || fail 'DHCP range start должен быть 192.168.100.100'
/usr/bin/test "$end" = 192.168.100.200 || fail 'DHCP range end должен быть 192.168.100.200'
/usr/bin/test "$host" = 192.168.100.10 || fail 'нет host reservation 52:54:00:aa:10:01 -> 192.168.100.10'
