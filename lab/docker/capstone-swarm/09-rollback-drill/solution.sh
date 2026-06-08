#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
install -d /home/ubuntu/capstone-swarm/src/orders-bad
cat > /home/ubuntu/capstone-swarm/src/orders-bad/app.py <<'PYAPP'
import sys
print('intentional bad release',flush=True)
sys.exit(42)
PYAPP
cat > /home/ubuntu/capstone-swarm/src/orders-bad/Dockerfile <<'EOF'
FROM python:3.12-alpine
COPY app.py /app.py
ENTRYPOINT ["python","/app.py"]
EOF
docker build -t localhost:5000/market-orders:bad /home/ubuntu/capstone-swarm/src/orders-bad
docker push localhost:5000/market-orders:bad
docker service update --image localhost:5000/market-orders:bad --update-parallelism 1 --update-delay 1s --update-monitor 5s --update-failure-action pause market_orders-api >/dev/null
failed_task=
for _ in $(seq 1 90); do
  failed_task=$(docker service ps --no-trunc --format '{{.ID}} {{.CurrentState}}' market_orders-api | awk '/Failed/{print $1; exit}')
  [ -n "$failed_task" ] && break
  sleep 2
done
[ -n "$failed_task" ] || { echo "Bad release не создал failed task" >&2; exit 1; }
docker service rollback market_orders-api >/dev/null
for _ in $(seq 1 120); do
  state=$(docker service inspect --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' market_orders-api)
  if [ "$state" = rollback_completed ] && curl -fsS http://127.0.0.1:8080/orders/version >/dev/null 2>&1; then break; fi
  sleep 2
done
[ "$state" = rollback_completed ] || { echo "Rollback timeout" >&2; exit 1; }
jq -n --arg bad_image 'localhost:5000/market-orders:bad' --arg failed_task "$failed_task" --arg rollback_state "$state" '{bad_image:$bad_image,failed_task:$failed_task,rollback_state:$rollback_state,recovered_version:"2.0"}' > /home/ubuntu/capstone-swarm/evidence/rollback.json
chown -R ubuntu:ubuntu /home/ubuntu/capstone-swarm/evidence/rollback.json /home/ubuntu/capstone-swarm/src/orders-bad
