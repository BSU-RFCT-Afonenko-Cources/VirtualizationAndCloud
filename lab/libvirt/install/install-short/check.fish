#!/bin/fish
virsh dumpxml alpine-short >/home/ubuntu/install-short/alpine-short.xml 2>/dev/null; or exit 1
grep -q '/home/ubuntu/alpine.iso' /home/ubuntu/install-short/alpine-short.xml; or exit 1
grep -Eq '<memory unit='KiB'>[0-9]+' /home/ubuntu/install-short/alpine-short.xml; or exit 1
grep -q '/home/ubuntu/install-short/alpine-short.qcow2' /home/ubuntu/install-short/alpine-short.xml; or exit 1
