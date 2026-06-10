#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/ubuntu/shop/config /home/ubuntu/shop/evidence
cat > /home/ubuntu/shop/stack.yml <<'YAML'
version: "3.9"

services:
  web:
    image: nginx:1.27-alpine
    ports:
      - target: 80
        published: 8080
        protocol: tcp
        mode: ingress
    networks:
      - backend
    configs:
      - source: shop_nginx_v1
        target: /etc/nginx/conf.d/default.conf
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      update_config:
        parallelism: 1
        delay: 5s
        order: start-first
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1/health >/dev/null"]
      interval: 10s
      timeout: 3s
      retries: 6

  api:
    image: shop-api:v1
    environment:
      DB_HOST: db
      DB_NAME: shop
      DB_USER: shop_user
      DB_PASSWORD_FILE: /run/secrets/db_password
      APP_CONFIG: /app/config.json
    networks:
      - backend
    secrets:
      - source: shop_db_password_v1
        target: db_password
    configs:
      - source: shop_api_config_v1
        target: /app/config.json
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      update_config:
        parallelism: 1
        delay: 5s
        order: start-first
        failure_action: rollback
    healthcheck:
      test: ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).read()\""]
      interval: 10s
      timeout: 3s
      retries: 6

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: shop
      POSTGRES_USER: shop_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      PGDATA: /home/ubuntu/shop/postgresql-data
    volumes:
      - db_data:/home/ubuntu/shop/postgresql-data
    networks:
      - backend
    secrets:
      - source: shop_db_password_v1
        target: db_password
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      update_config:
        parallelism: 1
        delay: 5s
        order: stop-first
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U shop_user -d shop"]
      interval: 10s
      timeout: 3s
      retries: 10

networks:
  backend:
    driver: overlay

volumes:
  db_data:
    name: shop_db_data

secrets:
  shop_db_password_v1:
    external: true

configs:
  shop_nginx_v1:
    external: true
  shop_api_config_v1:
    external: true
YAML
chown -R ubuntu:ubuntu /home/ubuntu/shop
