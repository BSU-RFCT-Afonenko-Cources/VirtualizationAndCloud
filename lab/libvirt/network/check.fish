#!/bin/fish
virsh net-list --all 2>/dev/null | grep -q isolated-lab; or exit 1
virsh net-info isolated-lab 2>/dev/null | grep -q 'Active:[[:space:]]*yes'; or exit 1
virsh net-info isolated-lab 2>/dev/null | grep -q 'Autostart:[[:space:]]*yes'; or exit 1
