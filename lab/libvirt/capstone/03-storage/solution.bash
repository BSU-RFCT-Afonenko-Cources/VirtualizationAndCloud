#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Создаём persistent directory pool и минимальный набор volumes для будущих ВМ.
D=/home/ubuntu/capstone/03-storage; ensure_dir "$D"; /usr/bin/sudo -n /usr/bin/install -d -m 0755 /var/lib/libvirt/capstone
if ! "${VIRSH[@]}" pool-info capstone-pool >/dev/null 2>&1; then "${VIRSH[@]}" pool-define-as capstone-pool dir --target /var/lib/libvirt/capstone >/dev/null; fi
"${VIRSH[@]}" pool-start capstone-pool >/dev/null 2>&1 || true; "${VIRSH[@]}" pool-autostart capstone-pool >/dev/null
for spec in 'cap-edge.qcow2 8G' 'cap-app.qcow2 8G' 'cap-db.qcow2 8G' 'cap-db-data.qcow2 2G'; do set -- $spec; "${VIRSH[@]}" vol-info --pool capstone-pool "$1" >/dev/null 2>&1 || "${VIRSH[@]}" vol-create-as capstone-pool "$1" "$2" --allocation 0 --format qcow2 >/dev/null; done
"${VIRSH[@]}" pool-dumpxml capstone-pool >"$D/pool.xml"; "${VIRSH[@]}" vol-list capstone-pool --details >"$D/volumes.txt"; /usr/bin/sudo -n /usr/bin/chown -R ubuntu:ubuntu "$D"
