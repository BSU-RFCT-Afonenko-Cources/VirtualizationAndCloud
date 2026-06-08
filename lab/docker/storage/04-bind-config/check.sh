#!/bin/bash
set -euo pipefail
/usr/bin/python3 -c 'import json; c=json.load(open("/home/ubuntu/storage/config/api.json")); assert c == {"service_name":"storage-api","dataset":"/data/records.json"}'
[ "$(/usr/bin/docker inspect --format '{{.State.Health.Status}}' storage-api)" = healthy ] || { /usr/bin/echo 'storage-api не healthy'; exit 1; }
/usr/bin/python3 - <<'PYDOCKER'
import json, subprocess
info = json.loads(subprocess.check_output(['/usr/bin/docker', 'inspect', 'storage-api']))[0]
mounts = {m['Destination']: m for m in info['Mounts']}
assert mounts['/data']['Type'] == 'volume' and mounts['/data']['Name'] == 'lab-data' and not mounts['/data']['RW'], 'lab-data должен быть read-only volume'
for destination, source in [('/app/config.json', '/home/ubuntu/storage/config/api.json'), ('/app/api.py', '/home/ubuntu/storage/assets/api.py')]:
    mount = mounts[destination]
    assert mount['Type'] == 'bind' and mount['Source'] == source and not mount['RW'], f'{destination} должен быть read-only bind mount'
bindings = info['HostConfig']['PortBindings']['8080/tcp']
assert bindings == [{'HostIp': '127.0.0.1', 'HostPort': '8080'}], 'порт должен быть опубликован как 127.0.0.1:8080'
PYDOCKER
/usr/bin/curl --fail --silent http://127.0.0.1:8080/records | /usr/bin/python3 -c 'import json,sys; p=json.load(sys.stdin); assert p["service"] == "storage-api"; assert any(r.get("id") == "persistent-1" for r in p["records"])'
