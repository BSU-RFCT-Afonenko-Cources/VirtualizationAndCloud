#!/usr/bin/env bash
set -euo pipefail
DIR=/home/ubuntu/snapshot-preview
/usr/bin/install -d -o ubuntu -g ubuntu -m 0755 "$DIR"
/usr/bin/rm -f /tmp/libvirt-snapshots/lab-preview.qcow2
/usr/bin/virsh -c qemu:///system snapshot-create-as lab-vm lab-preview --description 'External disk-only preview' --disk-only --diskspec vda,snapshot=external,file=/tmp/libvirt-snapshots/lab-preview.qcow2 --print-xml >"$DIR/lab-preview.xml"
/usr/bin/chown -R ubuntu:ubuntu "$DIR"
