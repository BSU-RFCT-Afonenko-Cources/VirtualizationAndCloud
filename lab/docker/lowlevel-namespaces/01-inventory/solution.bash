#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/01-inventory.json
shell_pid=$(/usr/bin/pgrep -u ubuntu -n -x bash || /usr/bin/pgrep -u ubuntu -n -x sh)
docker_pid=$(/usr/bin/pgrep -o -x dockerd || /usr/bin/printf '0')
/usr/bin/python3 -c 'import json,os,pathlib,socket,sys
pids=[int(sys.argv[1])]+([int(sys.argv[2])] if int(sys.argv[2]) else [])
procs=[]
for pid in pids:
 d=pathlib.Path(f"/proc/{pid}/ns")
 if d.exists(): procs.append({"pid":pid,"namespaces":{p.name:os.readlink(p) for p in d.iterdir()}})
types=sorted({k for p in procs for k in p["namespaces"]})
pathlib.Path(sys.argv[3]).write_text(json.dumps({"shell_pid":pids[0],"docker_pid":pids[1] if len(pids)>1 else None,"host_hostname":socket.gethostname(),"observed_types":types,"processes":procs},indent=2)+"\n")' "$shell_pid" "$docker_pid" "$f"
/usr/bin/chown ubuntu:ubuntu "$f"
