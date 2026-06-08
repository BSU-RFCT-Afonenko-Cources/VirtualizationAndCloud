#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/ubuntu/shop/config
if ! docker secret inspect shop_db_password_v2 >/dev/null 2>&1; then
  printf '%s' 'SwarmLab-DB-v2!' | docker secret create shop_db_password_v2 - >/dev/null
fi
cid=$(docker ps --filter label=com.docker.swarm.service.name=shop_db --format '{{.ID}}' | head -n 1)
if [ -n "$cid" ]; then
  docker exec -e PGPASSWORD='SwarmLab-DB-v1!' "$cid" psql -U shop_user -d shop -c "alter user shop_user with password 'SwarmLab-DB-v2!';" >/dev/null || \
  docker exec -e PGPASSWORD='SwarmLab-DB-v2!' "$cid" psql -U shop_user -d shop -c "select 1;" >/dev/null
fi
cat > /home/ubuntu/shop/config/api-v2-rotated.json <<'EOF_JSON'
{
  "app": "shop",
  "version": "v1",
  "rotated": true
}
EOF_JSON
if ! docker config inspect shop_api_config_v2 >/dev/null 2>&1; then
  docker config create shop_api_config_v2 /home/ubuntu/shop/config/api-v2-rotated.json >/dev/null
fi
python3 - <<'PY'
from pathlib import Path
p=Path('/home/ubuntu/shop/stack.yml')
s=p.read_text()
s=s.replace('shop_db_password_v1', 'shop_db_password_v2')
s=s.replace('shop_api_config_v1', 'shop_api_config_v2')
s=s.replace('shop_api_config_v2:\n    external: true', 'shop_api_config_v2:\n    external: true')
s=s.replace('shop_db_password_v2:\n    external: true', 'shop_db_password_v2:\n    external: true')
if 'shop_api_config_v2:' not in s.split('configs:',1)[1]:
    s=s.replace('  shop_api_config_v1:\n    external: true', '  shop_api_config_v2:\n    external: true')
if 'shop_db_password_v2:' not in s.split('secrets:',1)[1].split('configs:',1)[0]:
    s=s.replace('  shop_db_password_v1:\n    external: true', '  shop_db_password_v2:\n    external: true')
p.write_text(s)
PY
docker stack deploy -c /home/ubuntu/shop/stack.yml shop >/dev/null
for _ in $(seq 1 90); do
  if curl -fsS http://127.0.0.1:8080/api/products/swarm-book | grep -q 'Swarm Book' && curl -fsS http://127.0.0.1:8080/api/version | grep -q '"rotated": true'; then
    docker secret rm shop_db_password_v1 >/dev/null 2>&1 || true
    docker config rm shop_api_config_v1 >/dev/null 2>&1 || true
    exit 0
  fi
  sleep 2
done
exit 1
