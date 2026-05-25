#!/bin/fish
mkdir -p /home/ubuntu/pool/storage
virsh pool-define-as lab-pool dir --target /home/ubuntu/pool/storage >/dev/null 2>/dev/null; or true
virsh pool-start lab-pool >/dev/null 2>/dev/null; or true
virsh pool-autostart lab-pool >/dev/null 2>/dev/null; or true
