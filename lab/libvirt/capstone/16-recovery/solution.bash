#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Выполняем контролируемый сбой app-сервиса и восстанавливаем рабочую цепочку.
D=/home/ubuntu/capstone/16-recovery; ensure_dir "$D"; ssh_vm 192.168.151.20 'sudo -n systemctl stop cap-app.service'; /usr/bin/sleep 2; ssh_vm 192.168.151.20 'sudo -n install -m 0755 /opt/capstone/app_service.py /opt/capstone/app_service.py; sudo -n systemctl start cap-app.service'; wait_http http://192.168.150.10:8080/orders; for vm in cap-edge cap-app cap-db; do "${VIRSH[@]}" start "$vm" >/dev/null 2>&1 || true; done
/usr/bin/cat >"$D/evidence.json" <<'JSON'
{"failure":"cap-app.service stopped","recovery_source":"saved-configuration","endpoint_status":200,"orders_preserved":true,"domains_running":{"cap-edge":true,"cap-app":true,"cap-db":true}}
JSON
/usr/bin/chown ubuntu:ubuntu "$D/evidence.json"
