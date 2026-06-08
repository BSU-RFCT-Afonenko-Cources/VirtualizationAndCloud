#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Собираем базовую инвентаризацию libvirt-хоста в проверяемые файлы.
D=/home/ubuntu/capstone/01-inventory; ensure_dir "$D"
"${VIRSH[@]}" list --all >"$D/domains.txt"; "${VIRSH[@]}" net-list --all >"$D/networks.txt"; "${VIRSH[@]}" pool-list --all >"$D/pools.txt"; "${VIRSH[@]}" nodeinfo >"$D/nodeinfo.txt"; "${VIRSH[@]}" capabilities >"$D/capabilities.xml"; /usr/bin/sudo -n /usr/bin/chown -R ubuntu:ubuntu "$D"
