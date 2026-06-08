#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
rm -rf /home/ubuntu/capstone-swarm/backup
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm/backup/configs
cp /home/ubuntu/capstone-swarm/market-stack.yml /home/ubuntu/capstone-swarm/backup/market-stack.yml
jq -n --arg id "$(docker secret inspect --format '{{.ID}}' market_db_password)" '[{id:$id,name:"market_db_password",driver:"swarm"}]' > /home/ubuntu/capstone-swarm/backup/secrets-inventory.json
for config in market_edge_routes market_api_config; do
  docker config inspect --format '{{.Spec.Data}}' "$config" | base64 -d > "/home/ubuntu/capstone-swarm/backup/configs/$config"
done
db_container=$(docker ps --filter label=com.docker.swarm.service.name=market_db --format '{{.ID}}' | head -1)
docker exec "$db_container" pg_dump -U market -d market > /home/ubuntu/capstone-swarm/backup/market.sql
find /home/ubuntu/capstone-swarm/backup -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > /home/ubuntu/capstone-swarm/backup/SHA256SUMS
chown -R ubuntu:ubuntu /home/ubuntu/capstone-swarm/backup
