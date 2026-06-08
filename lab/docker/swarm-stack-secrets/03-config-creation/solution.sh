#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/ubuntu/shop/config
cat > /home/ubuntu/shop/config/nginx.conf <<'EOF_NGINX'
server {
  listen 80;
  server_name _;

  location = /health {
    add_header Content-Type application/json;
    return 200 '{"status":"ok","service":"web"}';
  }

  location /api/ {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://api:8000/;
  }
}
EOF_NGINX
cat > /home/ubuntu/shop/config/api-v1.json <<'EOF_JSON'
{
  "app": "shop",
  "version": "v1",
  "rotated": false
}
EOF_JSON
if ! docker config inspect shop_nginx_v1 >/dev/null 2>&1; then
  docker config create shop_nginx_v1 /home/ubuntu/shop/config/nginx.conf >/dev/null
fi
if ! docker config inspect shop_api_config_v1 >/dev/null 2>&1; then
  docker config create shop_api_config_v1 /home/ubuntu/shop/config/api-v1.json >/dev/null
fi
chown -R ubuntu:ubuntu /home/ubuntu/shop
