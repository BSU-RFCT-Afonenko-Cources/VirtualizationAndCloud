#!/usr/bin/env python3
import json, os, urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
DB_URL=os.environ.get('CAP_DB_URL','http://192.168.151.30:54321')
VERSION_FILE=os.environ.get('CAP_VERSION_FILE','/etc/cap-app-version')
def fetch(path):
 with urllib.request.urlopen(DB_URL+path,timeout=3) as r: return json.load(r)
class H(BaseHTTPRequestHandler):
 def out(self,code,data):
  body=json.dumps(data).encode(); self.send_response(code); self.send_header('Content-Type','application/json'); self.send_header('X-Cap-Service','cap-app'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def do_GET(self):
  try:
   if self.path=='/health': return self.out(200,{'status':'ok','service':'cap-app','database':fetch('/health')['status']})
   if self.path=='/version':
    with open(VERSION_FILE,encoding='utf-8') as f: version=f.read().strip()
    return self.out(200,{'service':'cap-app','version':version})
   if self.path=='/orders':
    data=fetch('/orders'); data.update({'service':'cap-app','via':'cap-db'}); return self.out(200,data)
   self.out(404,{'error':'not found'})
  except Exception as e: self.out(503,{'status':'error','service':'cap-app','detail':str(e)})
 def log_message(self,fmt,*args): print('%s - %s'%(self.address_string(),fmt%args),flush=True)
ThreadingHTTPServer(('0.0.0.0',8000),H).serve_forever()
