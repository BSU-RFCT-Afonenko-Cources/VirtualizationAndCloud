#!/usr/bin/env bash
set -euo pipefail
cat > /home/ubuntu/compose-lab/compose.yaml <<'COMPOSE'
name: compose-lab

services:
  db:
    image: redis:7-alpine
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - db-data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 2s
      timeout: 2s
      retries: 15
      start_period: 2s

  api:
    build: ./api
    environment:
      DB_HOST: db
      DB_PORT: "6379"
    networks:
      - frontend
      - backend
    expose:
      - "8080"
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"]
      interval: 2s
      timeout: 2s
      retries: 15
      start_period: 3s
    depends_on:
      db:
        condition: service_healthy

  web:
    image: nginx:1.27-alpine
    ports:
      - "8080:80"
    volumes:
      - ./web/default.conf.template:/etc/nginx/templates/default.conf.template:ro
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost/health"]
      interval: 2s
      timeout: 2s
      retries: 15
      start_period: 3s
    depends_on:
      api:
        condition: service_healthy

networks:
  frontend:
  backend:
    internal: true

volumes:
  db-data:
COMPOSE
chown ubuntu:ubuntu /home/ubuntu/compose-lab/compose.yaml
cd /home/ubuntu/compose-lab
docker compose -p compose-lab up -d --build --scale api=3
