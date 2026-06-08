#!/bin/bash
set -euo pipefail
LAB=/home/ubuntu/capstone-swarm
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm /home/ubuntu/capstone-swarm/evidence
if ! docker ps --format '{{.Names}}' | grep -qx market-registry; then
  docker rm -f market-registry >/dev/null 2>&1 || true
  docker run -d --restart always --name market-registry -p 5000:5000 registry:2 >/dev/null
fi
install -d -o ubuntu -g ubuntu /home/ubuntu/capstone-swarm/src/{edge,orders,catalog,worker}
cat > /home/ubuntu/capstone-swarm/src/edge/app.py <<'PYAPP'
import http.client,json,os
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
routes=json.load(open('/run/configs/routes.json'))
class H(BaseHTTPRequestHandler):
 def do_GET(self): self.proxy()
 def do_POST(self): self.proxy()
 def proxy(self):
  prefix=next((p for p in routes if self.path.startswith(p)),None)
  if self.path=='/health': return self.send(200,b'{"status":"ok","service":"edge"}')
  if not prefix: return self.send(404,b'{"error":"route"}')
  host,port=routes[prefix].split(':'); body=self.rfile.read(int(self.headers.get('Content-Length','0')))
  try:
   c=http.client.HTTPConnection(host,int(port),timeout=5); c.request(self.command,self.path,body,{'Content-Type':self.headers.get('Content-Type','application/json')}); r=c.getresponse(); self.send(r.status,r.read(),r.getheader('Content-Type','application/json'))
  except Exception as e: self.send(502,json.dumps({'error':str(e)}).encode())
 def send(self,code,body,ctype='application/json'):
  self.send_response(code); self.send_header('Content-Type',ctype); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def log_message(self,*a): pass
ThreadingHTTPServer(('0.0.0.0',8080),H).serve_forever()
PYAPP
cat > /home/ubuntu/capstone-swarm/src/orders/app.py <<'PYAPP'
import json,os,time,uuid
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
import psycopg
VERSION=os.getenv('APP_VERSION','1.0')
def conn():
 return psycopg.connect(host=os.getenv('DB_HOST','db'),dbname=os.getenv('DB_NAME','market'),user=os.getenv('DB_USER','market'),password=open('/run/secrets/db_password').read().strip())
for _ in range(60):
 try:
  with conn() as c: c.execute('create table if not exists orders (id text primary key, item text not null, quantity int not null, created_at timestamptz default now())')
  break
 except Exception: time.sleep(2)
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path=='/health': return self.send(200,{'status':'ok','service':'orders-api','version':VERSION})
  if self.path=='/orders/version': return self.send(200,{'version':VERSION})
  if self.path.startswith('/orders/'):
   oid=self.path.split('/')[-1]
   with conn() as c: row=c.execute('select id,item,quantity from orders where id=%s',(oid,)).fetchone()
   return self.send(200,{'id':row[0],'item':row[1],'quantity':row[2]}) if row else self.send(404,{'error':'not found'})
  self.send(404,{'error':'route'})
 def do_POST(self):
  if self.path!='/orders': return self.send(404,{'error':'route'})
  data=json.loads(self.rfile.read(int(self.headers.get('Content-Length','0'))) or b'{}'); oid=str(uuid.uuid4())
  with conn() as c: c.execute('insert into orders(id,item,quantity) values(%s,%s,%s)',(oid,data.get('item','unknown'),int(data.get('quantity',1))))
  self.send(201,{'id':oid,'item':data.get('item','unknown'),'quantity':int(data.get('quantity',1)),'version':VERSION})
 def send(self,code,data):
  body=json.dumps(data).encode(); self.send_response(code); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def log_message(self,*a): pass
ThreadingHTTPServer(('0.0.0.0',8000),H).serve_forever()
PYAPP
cat > /home/ubuntu/capstone-swarm/src/catalog/app.py <<'PYAPP'
import json,os
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path=='/health': data={'status':'ok','service':'catalog-api'}
  elif self.path=='/catalog': data={'items':[{'sku':'book','price':25},{'sku':'keyboard','price':80}]}
  else: return self.send_error(404)
  body=json.dumps(data).encode(); self.send_response(200); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def log_message(self,*a): pass
ThreadingHTTPServer(('0.0.0.0',8000),H).serve_forever()
PYAPP
cat > /home/ubuntu/capstone-swarm/src/worker/app.py <<'PYAPP'
import os,time,psycopg
while True:
 try:
  password=open('/run/secrets/db_password').read().strip()
  with psycopg.connect(host=os.getenv('DB_HOST','db'),dbname='market',user='market',password=password) as c: c.execute('select count(*) from orders').fetchone()
 except Exception as e: print(e,flush=True)
 time.sleep(10)
PYAPP
cat > /home/ubuntu/capstone-swarm/src/edge/Dockerfile <<'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
USER 65532:65532
ENTRYPOINT ["python","/app/app.py"]
EOF
cat > /home/ubuntu/capstone-swarm/src/catalog/Dockerfile <<'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
USER 65532:65532
ENTRYPOINT ["python","/app/app.py"]
EOF
for app in orders worker; do
cat > "/home/ubuntu/capstone-swarm/src/$app/Dockerfile" <<'EOF'
FROM python:3.12-alpine
RUN pip install --no-cache-dir "psycopg[binary]==3.2.3"
WORKDIR /app
COPY app.py /app/app.py
USER 65532:65532
ENTRYPOINT ["python","/app/app.py"]
EOF
done
for app in edge orders catalog worker; do
  docker build -t "localhost:5000/market-$app:1.0" "/home/ubuntu/capstone-swarm/src/$app"
  docker push "localhost:5000/market-$app:1.0"
done
chown -R ubuntu:ubuntu /home/ubuntu/capstone-swarm/src
