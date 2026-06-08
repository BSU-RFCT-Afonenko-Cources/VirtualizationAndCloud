#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Фиксируем evidence сетевой сегментации и успешный entrypoint через cap-edge.
D=/home/ubuntu/capstone/10-isolation; ensure_dir "$D"; orders=$(/usr/bin/curl -fsS http://192.168.150.10:8080/orders); db=$(/usr/bin/curl -fsS http://192.168.151.30:54321/orders)
/usr/bin/python3 - "$D/evidence.json" "$orders" "$db" <<'PY2'
import json,sys
orders,db=map(json.loads,sys.argv[2:])
x={'entrypoint':'http://192.168.150.10:8080','nodes':{'cap-edge':{'front':'192.168.150.10','back':'192.168.151.10'},'cap-app':{'front':None,'back':'192.168.151.20'},'cap-db':{'front':None,'back':'192.168.151.30'}},'edge_check':{'status':200,'source':orders['source']},'app_db_check':{'status':200,'source':db['source']}}
json.dump(x,open(sys.argv[1],'w'),indent=2)
PY2
/usr/bin/chown ubuntu:ubuntu "$D/evidence.json"
