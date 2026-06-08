#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
node_id=$(docker info --format '{{.Swarm.NodeID}}')
hostname=$(docker node inspect --format '{{.Description.Hostname}}' "$node_id")
role=$(docker node inspect --format '{{.Spec.Role}}' "$node_id")
availability=$(docker node inspect --format '{{.Spec.Availability}}' "$node_id")
manager_state=$(docker node inspect --format '{{.ManagerStatus.Reachability}}' "$node_id")
jq -n --arg node_id "$node_id" --arg hostname "$hostname" --arg role "$role" --arg availability "$availability" --arg manager_state "$manager_state"   '{swarm:"active",node_id:$node_id,hostname:$hostname,role:$role,availability:$availability,manager_state:$manager_state}'   > /home/ubuntu/capstone-swarm/evidence/swarm-inventory.json
chown ubuntu:ubuntu /home/ubuntu/capstone-swarm/evidence/swarm-inventory.json
