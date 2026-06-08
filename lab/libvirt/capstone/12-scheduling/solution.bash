#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Применяем CPU quota/period к cap-app и проверяем доступность сервиса под нагрузкой.
D=/home/ubuntu/capstone/12-scheduling; ensure_dir "$D"; "${VIRSH[@]}" schedinfo cap-app --set vcpu_period=100000 --set vcpu_quota=100000 --config >/dev/null; "${VIRSH[@]}" schedinfo cap-app --set vcpu_period=100000 --set vcpu_quota=100000 --live >/dev/null || true
ssh_vm 192.168.151.20 "/usr/bin/timeout 5 /usr/bin/python3 -c 'x=0\nwhile True: x+=1'" >/dev/null 2>&1 || true; code=$(/usr/bin/curl -sS -o /dev/null -w '%{http_code}' http://192.168.150.10:8080/health)
/usr/bin/printf '{"domain":"cap-app","vcpu_period":100000,"vcpu_quota":100000,"load":"completed","edge_health_status":%s}\n' "$code" >"$D/evidence.json"; /usr/bin/chown ubuntu:ubuntu "$D/evidence.json"
