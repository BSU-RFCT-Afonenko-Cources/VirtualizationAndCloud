#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
cp /home/ubuntu/capstone-swarm/src/orders/app.py /home/ubuntu/capstone-swarm/src/orders/app-v2.py
sed -i "s/VERSION=os.getenv('APP_VERSION','1.0')/VERSION=os.getenv('APP_VERSION','2.0')/" /home/ubuntu/capstone-swarm/src/orders/app-v2.py
cat > /home/ubuntu/capstone-swarm/src/orders/Dockerfile.v2 <<'EOF'
FROM python:3.12-alpine
RUN pip install --no-cache-dir "psycopg[binary]==3.2.3"
WORKDIR /app
COPY app-v2.py /app/app.py
USER 65532:65532
ENTRYPOINT ["python","/app/app.py"]
EOF
docker build -f /home/ubuntu/capstone-swarm/src/orders/Dockerfile.v2 -t localhost:5000/market-orders:2.0 /home/ubuntu/capstone-swarm/src/orders
docker push localhost:5000/market-orders:2.0
docker service update --image localhost:5000/market-orders:2.0 --env-rm APP_VERSION --env-add APP_VERSION=2.0 --update-parallelism 1 --update-delay 5s --update-monitor 10s --update-failure-action pause --update-order start-first market_orders-api >/dev/null
for _ in $(seq 1 120); do
  state=$(docker service inspect --format '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' market_orders-api)
  [ "$state" = completed ] && break
  [ "$state" = paused ] && { echo "Rolling update paused" >&2; exit 1; }
  sleep 2
done
[ "$state" = completed ] || { echo "Rolling update timeout" >&2; exit 1; }
sed -i 's#localhost:5000/market-orders:1.0#localhost:5000/market-orders:2.0#' /home/ubuntu/capstone-swarm/market-stack.yml
sed -i '0,/APP_VERSION: "1.0"/s//APP_VERSION: "2.0"/' /home/ubuntu/capstone-swarm/market-stack.yml
chown -R ubuntu:ubuntu /home/ubuntu/capstone-swarm/src /home/ubuntu/capstone-swarm/market-stack.yml
