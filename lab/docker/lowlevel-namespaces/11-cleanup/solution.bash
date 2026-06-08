#!/bin/bash
set -euo pipefail
for pf in /home/ubuntu/ns-lab/state/*.pid; do [[ -f "$pf" ]] || continue; p=$(/usr/bin/cat "$pf"); /bin/kill "$p" 2>/dev/null || true; done
/usr/bin/pkill -f '/usr/local/lib/ns-lab/ns-demo' 2>/dev/null || true; /usr/bin/pkill -f '/usr/local/lib/ns-lab/ns-http' 2>/dev/null || true
/usr/bin/docker rm -f ns-docker-demo >/dev/null 2>&1 || true
/usr/sbin/ip netns del ns-lab-net 2>/dev/null || true; /usr/sbin/ip link del ns-lab-host 2>/dev/null || true
/bin/umount -l /home/ubuntu/ns-lab/mnt/private 2>/dev/null || true
/bin/rm -rf /home/ubuntu/ns-lab
/usr/bin/jq -n '{clean:true,removed:["processes","container","network namespace","veth","mounts","workspace"]}' > /home/ubuntu/ns-lab-cleanup.json
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/ns-lab-cleanup.json
