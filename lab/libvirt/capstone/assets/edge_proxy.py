#!/usr/bin/env python3
import urllib.error, urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
UPSTREAM='http://192.168.151.20:8000'
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  try:
   with urllib.request.urlopen(UPSTREAM+self.path,timeout=5) as r: status=r.status; body=r.read(); ctype=r.headers.get('Content-Type','application/json')
  except urllib.error.HTTPError as e: status=e.code; body=e.read(); ctype=e.headers.get('Content-Type','application/json')
  except Exception as e: status=502; body=('{"error":"bad gateway","detail":%r}'%str(e)).encode(); ctype='application/json'
  self.send_response(status); self.send_header('Content-Type',ctype); self.send_header('X-Cap-Edge','cap-edge'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def log_message(self,fmt,*args): print('%s - %s'%(self.address_string(),fmt%args),flush=True)
ThreadingHTTPServer(('0.0.0.0',8080),H).serve_forever()
