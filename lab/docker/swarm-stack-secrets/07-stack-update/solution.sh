#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/ubuntu/shop/config
cat > /home/ubuntu/shop/config/api-v3.json <<'EOF_JSON'
{
  "app": "shop",
  "version": "v2",
  "rotated": true
}
EOF_JSON
if ! docker config inspect shop_api_config_v3 >/dev/null 2>&1; then
  docker config create shop_api_config_v3 /home/ubuntu/shop/config/api-v3.json >/dev/null
fi
python3 - <<'PY'
from pathlib import Path
p=Path('/home/ubuntu/shop/stack.yml')
s=p.read_text().replace('shop-api:v1', 'shop-api:v2').replace('shop_api_config_v2', 'shop_api_config_v3').replace('shop_api_config_v1', 'shop_api_config_v3')
if 'shop_api_config_v3:' not in s.split('configs:',1)[1]:
    lines=s.splitlines()
    out=[]
    for line in lines:
        out.append(line)
        if line.strip() == 'shop_nginx_v1:':
            pass
    s=s.replace('  shop_api_config_v2:\n    external: true', '  shop_api_config_v3:\n    external: true')
p.write_text(s)
PY
docker stack deploy -c /home/ubuntu/shop/stack.yml shop >/dev/null
for _ in $(seq 1 90); do
  if curl -fsS http://127.0.0.1:8080/api/version | grep -q '"version": "v2"' && curl -fsS http://127.0.0.1:8080/api/products/swarm-book | grep -q 'Swarm Book'; then
    exit 0
  fi
  sleep 2
done
exit 1
