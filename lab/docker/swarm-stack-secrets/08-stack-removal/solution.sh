#!/usr/bin/env bash
set -euo pipefail
docker stack rm shop >/dev/null 2>&1 || true
for _ in $(seq 1 90); do
  if [ -z "$(docker service ls --filter label=com.docker.stack.namespace=shop -q)" ] && [ -z "$(docker network ls --filter label=com.docker.stack.namespace=shop -q)" ]; then
    break
  fi
  sleep 2
done
for name in shop_db_password_v1 shop_db_password_v2; do docker secret rm "$name" >/dev/null 2>&1 || true; done
for name in shop_nginx_v1 shop_api_config_v1 shop_api_config_v2 shop_api_config_v3; do docker config rm "$name" >/dev/null 2>&1 || true; done
docker volume rm shop_db_data >/dev/null 2>&1 || true
