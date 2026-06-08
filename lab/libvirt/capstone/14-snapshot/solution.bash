#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Создаём snapshot перед обновлением API и затем меняем версию приложения.
D=/home/ubuntu/capstone/14-snapshot; ensure_dir "$D"; if ! "${VIRSH[@]}" snapshot-info cap-app before-app-upgrade >/dev/null 2>&1; then "${VIRSH[@]}" snapshot-create-as cap-app before-app-upgrade --description 'Before API upgrade to 2.0.0' --disk-only --atomic >/dev/null; fi; ssh_vm 192.168.151.20 "echo 2.0.0 | sudo -n tee /etc/cap-app-version >/dev/null; sudo -n systemctl restart cap-app.service"; wait_http http://192.168.150.10:8080/health; /usr/bin/curl -fsS http://192.168.150.10:8080/version >"$D/version.json"; /usr/bin/curl -fsS http://192.168.150.10:8080/health >"$D/health.json"; /usr/bin/chown -R ubuntu:ubuntu "$D"
