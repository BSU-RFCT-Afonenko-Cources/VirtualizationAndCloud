#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/ubuntu/shop/evidence
if ! docker secret inspect shop_db_password_v1 >/dev/null 2>&1; then
  printf '%s' 'SwarmLab-DB-v1!' | docker secret create shop_db_password_v1 - >/dev/null
fi
python3 - <<'PY'
import json
from pathlib import Path
Path('/home/ubuntu/shop/evidence').mkdir(parents=True, exist_ok=True)
Path('/home/ubuntu/shop/evidence/secret.json').write_text(json.dumps({
  'secret': 'shop_db_password_v1',
  'delivery': '/run/secrets/db_password',
  'plaintext_in_environment': False
}, ensure_ascii=False, indent=2) + '\n')
PY
chown -R ubuntu:ubuntu /home/ubuntu/shop
