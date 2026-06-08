#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
cat > /home/ubuntu/capstone-swarm/market-stack.yml <<'YAML'
version: "3.8"
services:
  edge:
    image: localhost:5000/market-edge:1.0
    ports:
      - target: 8080
        published: 8080
        protocol: tcp
        mode: ingress
    networks: [frontend, backend]
    deploy: {replicas: 1}
  orders-api:
    image: localhost:5000/market-orders:1.0
    networks: [backend, data]
    deploy: {replicas: 1}
  catalog-api:
    image: localhost:5000/market-catalog:1.0
    networks: [backend]
    deploy: {replicas: 1}
  db:
    image: postgres:16-alpine
    environment: {POSTGRES_DB: market, POSTGRES_USER: market, POSTGRES_PASSWORD: bootstrap-only}
    networks: [data]
    deploy: {replicas: 1}
  worker:
    image: localhost:5000/market-worker:1.0
    networks: [data]
    deploy: {replicas: 1}
networks:
  frontend: {name: market_frontend, driver: overlay, attachable: true}
  backend: {name: market_backend, driver: overlay, attachable: true}
  data: {name: market_data, driver: overlay, attachable: true}
YAML
docker stack deploy --resolve-image always -c /home/ubuntu/capstone-swarm/market-stack.yml market
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/market-stack.yml
