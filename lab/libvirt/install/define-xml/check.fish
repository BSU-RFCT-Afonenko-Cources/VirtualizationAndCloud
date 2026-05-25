#!/bin/fish
test -f /home/ubuntu/define-xml/alpine-xml.xml; or exit 1
virsh dumpxml alpine-xml >/tmp/alpine-xml.xml 2>/dev/null; or exit 1
grep -q '/home/ubuntu/alpine.iso' /tmp/alpine-xml.xml; or exit 1
