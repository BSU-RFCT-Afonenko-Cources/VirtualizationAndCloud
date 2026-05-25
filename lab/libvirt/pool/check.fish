#!/bin/fish
virsh pool-info lab-pool >/tmp/lab-pool.info 2>/dev/null; or exit 1
grep -q "Active:[[:space:]]*yes" /tmp/lab-pool.info; or exit 1
grep -q "Autostart:[[:space:]]*yes" /tmp/lab-pool.info; or exit 1
