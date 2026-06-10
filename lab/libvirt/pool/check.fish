#!/bin/fish
virsh pool-info lab-pool >/home/ubuntu/pool/lab-pool.info 2>/dev/null; or exit 1
grep -q "Active:[[:space:]]*yes" /home/ubuntu/pool/lab-pool.info; or exit 1
grep -q "Autostart:[[:space:]]*yes" /home/ubuntu/pool/lab-pool.info; or exit 1
