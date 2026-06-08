#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Запускаем домены, включаем autostart и ждём доступности SSH для следующих шагов.
D=/home/ubuntu/capstone/06-lifecycle; ensure_dir "$D"; for vm in cap-edge cap-app cap-db; do "${VIRSH[@]}" start "$vm" >/dev/null 2>&1 || true; "${VIRSH[@]}" autostart "$vm" >/dev/null; done
wait_ssh 192.168.150.10; wait_ssh 192.168.151.20; wait_ssh 192.168.151.30
/usr/bin/cat >"$D/states.json" <<'JSON'
{"cap-edge":{"state":"running","autostart":true,"ssh_ready":true},"cap-app":{"state":"running","autostart":true,"ssh_ready":true},"cap-db":{"state":"running","autostart":true,"ssh_ready":true}}
JSON
/usr/bin/chown ubuntu:ubuntu "$D/states.json"
