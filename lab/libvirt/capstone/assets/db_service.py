#!/usr/bin/env python3
import json, os, sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
DB=os.environ.get('CAP_DB_PATH','/srv/cap-db/orders.sqlite3')
os.makedirs(os.path.dirname(DB),exist_ok=True)
with sqlite3.connect(DB) as c:
 c.execute('create table if not exists orders(id integer primary key, item text not null, quantity integer not null)')
 c.execute('insert or ignore into orders values(1001,"virtual-router",2)')
 c.execute('insert or ignore into orders values(1002,"storage-volume",1)')
class H(BaseHTTPRequestHandler):
 def out(self,code,data):
  body=json.dumps(data).encode(); self.send_response(code); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def do_GET(self):
  if self.path=='/health': return self.out(200,{'status':'ok','service':'cap-db','database':DB})
  if self.path=='/orders':
   with sqlite3.connect(DB) as c: rows=[dict(id=r[0],item=r[1],quantity=r[2]) for r in c.execute('select id,item,quantity from orders order by id')]
   return self.out(200,{'source':'cap-db','orders':rows})
  self.out(404,{'error':'not found'})
 def log_message(self,fmt,*args): print('%s - %s'%(self.address_string(),fmt%args),flush=True)
ThreadingHTTPServer(('0.0.0.0',54321),H).serve_forever()
