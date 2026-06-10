#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Публикуем API через edge reverse proxy на frontend-адресе.
D=/home/ubuntu/capstone/09-edge; ensure_dir "$D"; wait_ssh 192.168.150.10; ssh_vm 192.168.150.10 'mkdir -p /home/ubuntu/capstone/09-edge'; scp_vm /home/ubuntu/capstone/assets/edge_proxy.py 192.168.150.10 /home/ubuntu/capstone/09-edge/edge_proxy.py; scp_vm /home/ubuntu/capstone/assets/cap-edge.service 192.168.150.10 /home/ubuntu/capstone/09-edge/cap-edge.service
ssh_vm 192.168.150.10 "sudo -n chmod 0755 /home/ubuntu/capstone/09-edge/edge_proxy.py; sudo -n install -m 0644 /home/ubuntu/capstone/09-edge/cap-edge.service /etc/systemd/system/cap-edge.service; sudo -n systemctl daemon-reload; sudo -n systemctl enable --now cap-edge.service"
wait_http http://192.168.150.10:8080/health; for ep in health version orders; do /usr/bin/curl -fsS "http://192.168.150.10:8080/$ep" >"$D/$ep.json"; done; /usr/bin/chown -R ubuntu:ubuntu "$D"
