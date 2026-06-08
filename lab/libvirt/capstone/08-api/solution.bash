#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Разворачиваем stateless API, которое читает данные из cap-db по backend-сети.
D=/home/ubuntu/capstone/08-api; ensure_dir "$D"; wait_ssh 192.168.151.20; scp_vm /home/ubuntu/capstone/assets/app_service.py 192.168.151.20 /tmp/app_service.py; scp_vm /home/ubuntu/capstone/assets/cap-app.service 192.168.151.20 /tmp/cap-app.service
ssh_vm 192.168.151.20 "sudo -n install -d /opt/capstone; sudo -n install -m 0755 /tmp/app_service.py /opt/capstone/app_service.py; echo 1.0.0 | sudo -n tee /etc/cap-app-version >/dev/null; sudo -n install -m 0644 /tmp/cap-app.service /etc/systemd/system/cap-app.service; sudo -n systemctl daemon-reload; sudo -n systemctl enable --now cap-app.service"
wait_http http://192.168.151.20:8000/health; for ep in health version orders; do /usr/bin/curl -fsS "http://192.168.151.20:8000/$ep" >"$D/$ep.json"; done; ssh_vm 192.168.151.20 'sudo -n journalctl -u cap-app.service -n 30 --no-pager' >"$D/service.log"; /usr/bin/chown -R ubuntu:ubuntu "$D"
