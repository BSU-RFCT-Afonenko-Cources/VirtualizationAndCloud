#!/usr/bin/env python3
import errno, http.server, json, os, socket, subprocess, sys, time
from pathlib import Path

def status_caps():
    data = {}
    for line in Path('/proc/self/status').read_text().splitlines():
        if line.startswith(('Uid:', 'Gid:', 'CapEff:', 'CapBnd:', 'CapPrm:', 'NoNewPrivs:', 'Seccomp:')):
            k, v = line.split(':', 1)
            data[k] = v.strip()
    return data

def attempt(name):
    try:
        if name == 'uname':
            subprocess.check_call(['uname', '-a'], stdout=subprocess.DEVNULL)
        elif name == 'hostname':
            subprocess.check_call(['hostname', 'sec-demo-test'])
        elif name == 'mount':
            Path('/tmp/sec-demo-mnt').mkdir(exist_ok=True)
            subprocess.check_call(['mount', '-t', 'tmpfs', 'tmpfs', '/tmp/sec-demo-mnt'])
            subprocess.call(['umount', '/tmp/sec-demo-mnt'])
        elif name == 'raw_socket':
            s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP); s.close()
        elif name == 'restricted_read':
            Path('/proc/1/mem').open('rb').read(1)
        elif name == 'mknod':
            subprocess.check_call(['mknod', '/tmp/sec-demo-null', 'c', '1', '3'])
        elif name == 'setuid_probe':
            p = subprocess.run(['/usr/local/bin/setuid-probe'], text=True, capture_output=True)
            return {'ok': p.returncode == 0, 'returncode': p.returncode, 'stdout': p.stdout.strip(), 'stderr': p.stderr.strip()}
        elif name == 'write_rootfs':
            Path('/rootfs-write-test').write_text('write-test')
        elif name == 'write_runtime':
            Path('/run/sec-demo/state.txt').write_text(str(time.time()))
        return {'ok': True, 'error': None}
    except Exception as e:
        return {'ok': False, 'error': str(e), 'errno': getattr(e, 'errno', None)}

def report():
    ops = ['uname', 'hostname', 'mount', 'raw_socket', 'restricted_read', 'mknod', 'setuid_probe', 'write_rootfs', 'write_runtime']
    return {'pid': os.getpid(), 'hostname': Path('/etc/hostname').read_text().strip(), 'status': status_caps(), 'ops': {op: attempt(op) for op in ops}}

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return
    def do_GET(self):
        if self.path == '/health':
            body = b'ok\n'; self.send_response(200); self.end_headers(); self.wfile.write(body); return
        if self.path.startswith('/diag'):
            body = json.dumps(report(), indent=2).encode(); self.send_response(200)
            self.send_header('Content-Type', 'application/json'); self.end_headers(); self.wfile.write(body); return
        self.send_response(404); self.end_headers()

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'diag':
        print(json.dumps(report(), indent=2)); sys.exit(0)
    port = int(os.environ.get('PORT', '8080'))
    http.server.ThreadingHTTPServer(('0.0.0.0', port), Handler).serve_forever()
