#!/bin/fish
qemu-img create -f qcow2 /home/ubuntu/install-short/alpine-short.qcow2 1G >/dev/null 2>/dev/null; or true
virt-install \
 --name alpine-short \
 --memory 448 \
 --vcpus 1 \
 --disk path=/home/ubuntu/install-short/alpine-short.qcow2,format=qcow2,size=1 \
 --cdrom /home/ubuntu/alpine.iso \
 --os-variant alpinelinux3.21 \
 --network network=default \
 --graphics none \
 --noautoconsole \
 --import >/dev/null 2>/dev/null; or true
