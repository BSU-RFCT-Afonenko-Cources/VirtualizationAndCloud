#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
docker service update --constraint-add 'node.role==manager' --reserve-cpu 0.10 --reserve-memory 32M --limit-cpu 0.50 --limit-memory 128M market_worker >/dev/null
docker service update --reserve-cpu 0.10 --reserve-memory 32M --limit-cpu 0.75 --limit-memory 192M market_orders-api >/dev/null
docker service update --reserve-cpu 0.05 --reserve-memory 16M --limit-cpu 0.50 --limit-memory 128M market_catalog-api >/dev/null
python3 - <<'PYCODE'
p = '/home/ubuntu/capstone-swarm/market-stack.yml'
s = open(p).read()

def add_before_restart(service, next_service, block):
    global s
    before, rest = s.split('  ' + service + ':', 1)
    section, after = rest.split('  ' + next_service + ':', 1)
    marker = '      restart_policy:'
    section = section.replace(marker, block + '\n' + marker, 1)
    s = before + '  ' + service + ':' + section + '  ' + next_service + ':' + after

add_before_restart('orders-api', 'catalog-api', '''      resources:
        reservations: {cpus: "0.10", memory: 32M}
        limits: {cpus: "0.75", memory: 192M}''')
add_before_restart('catalog-api', 'db', '''      resources:
        reservations: {cpus: "0.05", memory: 16M}
        limits: {cpus: "0.50", memory: 128M}''')
before, worker = s.split('  worker:', 1)
marker = '      restart_policy:'
block = '''      placement: {constraints: [node.role == manager]}
      resources:
        reservations: {cpus: "0.10", memory: 32M}
        limits: {cpus: "0.50", memory: 128M}'''
worker = worker.replace(marker, block + '\n' + marker, 1)
open(p, 'w').write(before + '  worker:' + worker)
PYCODE
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/market-stack.yml
