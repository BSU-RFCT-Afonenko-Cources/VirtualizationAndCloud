#!/bin/bash
set -euo pipefail
f=/home/ubuntu/ns-lab/evidence/10-docker.json
/usr/bin/docker rm -f ns-docker-demo >/dev/null 2>&1 || true
image=busybox:1.36
/usr/bin/docker image inspect "$image" >/dev/null 2>&1 || /usr/bin/docker pull "$image" >/dev/null
/usr/bin/docker run -d --name ns-docker-demo "$image" /bin/sh -c 'while :; do sleep 30; done' >/dev/null
p=$(/usr/bin/docker inspect -f '{{.State.Pid}}' ns-docker-demo); image=$(/usr/bin/docker inspect -f '{{.Config.Image}}' ns-docker-demo)
/usr/bin/python3 -c 'import json,os,pathlib,sys
p=int(sys.argv[1]); ns={x.name:os.readlink(x) for x in pathlib.Path(f"/proc/{p}/ns").iterdir()}
pathlib.Path(sys.argv[3]).write_text(json.dumps({"container":"ns-docker-demo","running":True,"host_pid":p,"image":sys.argv[2],"namespaces":ns},indent=2)+"\n")' "$p" "$image" "$f"
/usr/bin/chown ubuntu:ubuntu "$f"
