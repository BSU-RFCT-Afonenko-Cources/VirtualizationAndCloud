#!/usr/bin/env bash
set -euo pipefail
cat > /home/ubuntu/compose-lab/compose.yaml <<'COMPOSE'
name: compose-lab

services:
  db:
    image: redis:7-alpine
    networks:
      - backend

  api:
    build: ./api
    networks:
      - frontend
      - backend
    expose:
      - "8080"

  web:
    image: nginx:1.27-alpine
    ports:
      - "8080:80"
    volumes:
      - ./web/default.conf.template:/etc/nginx/templates/default.conf.template:ro
    networks:
      - frontend

networks:
  frontend:
  backend:
    internal: true
COMPOSE
chown ubuntu:ubuntu /home/ubuntu/compose-lab/compose.yaml
cd /home/ubuntu/compose-lab
docker compose -p compose-lab up -d --build
