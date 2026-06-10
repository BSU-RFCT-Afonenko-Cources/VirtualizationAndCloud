#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
if ! docker secret inspect market_db_password >/dev/null 2>&1; then
  printf '%s' 'swarm-capstone-db-2026' | docker secret create market_db_password - >/dev/null
fi
if ! docker config inspect market_edge_routes >/dev/null 2>&1; then
  printf '%s
' '{"/orders":"orders-api:8000","/catalog":"catalog-api:8000"}' | docker config create market_edge_routes - >/dev/null
fi
if ! docker config inspect market_api_config >/dev/null 2>&1; then
  printf '%s
' '{"service":"market","database":"market","log_level":"info"}' | docker config create market_api_config - >/dev/null
fi
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
    configs:
      - source: edge_routes
        target: /run/configs/routes.json
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      replicas: 1
      restart_policy: {condition: on-failure}
  orders-api:
    image: localhost:5000/market-orders:1.0
    environment:
      DB_HOST: db
      DB_NAME: market
      DB_USER: market
      APP_CONFIG: /run/configs/api.json
      APP_VERSION: "1.0"
    networks: [backend, data]
    secrets:
      - source: db_password
        target: db_password
    configs:
      - source: api_config
        target: /run/configs/api.json
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8000/health"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      replicas: 1
      endpoint_mode: vip
      restart_policy: {condition: on-failure}
      update_config: {parallelism: 1, delay: 5s, monitor: 10s, failure_action: pause, order: start-first}
      rollback_config: {parallelism: 1, delay: 2s, monitor: 10s, failure_action: pause, order: stop-first}
  catalog-api:
    image: localhost:5000/market-catalog:1.0
    networks: [backend]
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8000/health"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      replicas: 1
      endpoint_mode: vip
      restart_policy: {condition: on-failure}
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: market
      POSTGRES_USER: market
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      PGDATA: /home/ubuntu/capstone-swarm/postgresql-data
    networks: [data]
    secrets:
      - source: db_password
        target: db_password
    volumes:
      - db-data:/home/ubuntu/capstone-swarm/postgresql-data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U market -d market"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      replicas: 1
      placement: {constraints: [node.role == manager]}
      restart_policy: {condition: on-failure}
  worker:
    image: localhost:5000/market-worker:1.0
    environment: {DB_HOST: db}
    networks: [data]
    secrets:
      - source: db_password
        target: db_password
    configs:
      - source: api_config
        target: /run/configs/api.json
    deploy:
      replicas: 1
      restart_policy: {condition: on-failure}
networks:
  frontend: {name: market_frontend, driver: overlay, attachable: true}
  backend: {name: market_backend, driver: overlay, attachable: true}
  data: {name: market_data, driver: overlay, attachable: true}
volumes:
  db-data: {name: market_db-data}
secrets:
  db_password: {external: true, name: market_db_password}
configs:
  edge_routes: {external: true, name: market_edge_routes}
  api_config: {external: true, name: market_api_config}
YAML
docker stack deploy --resolve-image always -c /home/ubuntu/capstone-swarm/market-stack.yml market
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/market-stack.yml
