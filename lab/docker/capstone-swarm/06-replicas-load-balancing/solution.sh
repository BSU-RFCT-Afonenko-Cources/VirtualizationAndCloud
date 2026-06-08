#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
docker service scale market_orders-api=3 market_catalog-api=2 >/dev/null
python3 - <<'PYCODE'
p = '/home/ubuntu/capstone-swarm/market-stack.yml'
s = open(p).read()
before, rest = s.split('  orders-api:', 1)
orders, rest = rest.split('  catalog-api:', 1)
catalog, after = rest.split('  db:', 1)
orders = orders.replace('replicas: 1', 'replicas: 3', 1)
catalog = catalog.replace('replicas: 1', 'replicas: 2', 1)
open(p, 'w').write(before + '  orders-api:' + orders + '  catalog-api:' + catalog + '  db:' + after)
PYCODE
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/market-stack.yml
