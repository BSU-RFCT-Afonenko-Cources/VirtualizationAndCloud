#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Настраиваем отдельный data disk, SQLite-backed HTTP DB service и evidence-файл.
D=/home/ubuntu/capstone/07-database; ensure_dir "$D"; wait_ssh 192.168.151.30
ssh_vm 192.168.151.30 'mkdir -p /home/ubuntu/capstone/07-database/data'
scp_vm /home/ubuntu/capstone/assets/db_service.py 192.168.151.30 /home/ubuntu/capstone/07-database/db_service.py; scp_vm /home/ubuntu/capstone/assets/cap-db.service 192.168.151.30 /home/ubuntu/capstone/07-database/cap-db.service
ssh_vm 192.168.151.30 "sudo -n bash -c 'if ! blkid /dev/vdb >/dev/null 2>&1; then mkfs.ext4 -F /dev/vdb; fi; mkdir -p /home/ubuntu/capstone/07-database/data; grep -q /home/ubuntu/capstone/07-database/data /etc/fstab || echo /dev/vdb /home/ubuntu/capstone/07-database/data ext4 defaults,nofail 0 2 >>/etc/fstab; mountpoint -q /home/ubuntu/capstone/07-database/data || mount /home/ubuntu/capstone/07-database/data; chmod 0755 /home/ubuntu/capstone/07-database/db_service.py; install -m 0644 /home/ubuntu/capstone/07-database/cap-db.service /etc/systemd/system/cap-db.service; systemctl daemon-reload; systemctl enable --now cap-db.service'"
wait_http http://192.168.151.30:54321/orders; count=$(/usr/bin/curl -fsS http://192.168.151.30:54321/orders | /usr/bin/python3 -c 'import json,sys;print(len(json.load(sys.stdin)["orders"]))')
/usr/bin/printf '{"mount":"/home/ubuntu/capstone/07-database/data","device":"/dev/vdb","service":"active","orders":%s}\n' "$count" >"$D/evidence.json"; /usr/bin/chown ubuntu:ubuntu "$D/evidence.json"
