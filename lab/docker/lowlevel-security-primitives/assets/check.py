#!/usr/bin/env python3
import json, os, subprocess, sys
from pathlib import Path
step=sys.argv[1]
E=Path('/home/ubuntu/lowlevel-security-primitives/evidence')
def need(name):
    p=E/name
    if not p.is_file() or p.stat().st_size == 0: raise SystemExit(f'Отсутствует evidence: {p}')
    return p
def js(name): return json.loads(need(name).read_text())
def inspect(name):
    x=js(name)
    if not isinstance(x,list) or not x: raise SystemExit(f'Некорректный inspect: {name}')
    return x[0]
def running(name):
    p=subprocess.run(['/usr/bin/docker','inspect','-f','{{.State.Running}}',name],capture_output=True,text=True)
    return p.returncode == 0 and p.stdout.strip() == 'true'
def status(name,key):
    for line in need(name).read_text().splitlines():
        if line.startswith(key+':'): return line.split(':',1)[1].strip()
    raise SystemExit(f'{key} отсутствует в {name}')
if step=='01':
    x=inspect('baseline-inspect.json'); need('baseline-mountinfo.txt'); need('baseline-userns.txt'); need('baseline-devices.txt'); d=js('baseline-diag.json')
    assert x['State']['Running'] and 'CapEff' in d['status'] and int(d['status']['Seccomp']) >= 0
elif step=='02':
    a=inspect('cap-default-inspect.json'); b=inspect('cap-minimal-inspect.json')
    assert b['HostConfig']['CapDrop'] == ['ALL'] and 'NET_RAW' in b['HostConfig']['CapAdd']
    assert status('cap-default-status.txt','CapEff') != status('cap-minimal-status.txt','CapEff')
elif step=='03':
    denied=js('sysadmin-denied.json'); allowed=js('sysadmin-allowed.json'); x=inspect('sysadmin-inspect.json')
    assert not denied['ops']['mount']['ok'] and allowed['ops']['mount']['ok'] and 'SYS_ADMIN' in x['HostConfig']['CapAdd']
    assert not running('lsp-sysadmin')
elif step=='04':
    x=js('userns-classification.json'); assert x['classification'] in ('remapped','identity-map','unavailable')
    if x['supported']: need('userns-uid-map.txt'); need('userns-gid-map.txt')
elif step=='05':
    x=js('docker-mode.json'); need('docker-info.json'); need('docker-info.txt')
    assert x['mode'] in ('rootful','rootless') and isinstance(x['security_options'],list)
elif step=='06':
    a=js('seccomp-default-diag.json'); b=js('seccomp-custom-diag.json'); x=inspect('seccomp-custom-inspect.json')
    assert a['ops']['uname']['ok'] and not b['ops']['uname']['ok']
    assert any(str(v).startswith('seccomp=') for v in x['HostConfig']['SecurityOpt'])
    assert status('seccomp-custom-status.txt','Seccomp') == '2'
elif step=='07':
    off=need('nnp-off-probe.txt').read_text(); on=need('nnp-on-probe.txt').read_text(); x=inspect('nnp-on-inspect.json')
    assert 'euid=0' in off and 'euid=10001' in on and 'no_new_privileges=1' in on
    assert any('no-new-privileges' in str(v) for v in x['HostConfig']['SecurityOpt'])
elif step=='08':
    x=inspect('readonly-inspect.json'); d=js('readonly-diag.json')
    assert x['HostConfig']['ReadonlyRootfs'] and len(x['HostConfig']['Tmpfs']) >= 2
    assert not d['ops']['write_rootfs']['ok'] and d['ops']['write_runtime']['ok'] and x['State']['Running']
elif step=='09':
    x=inspect('privileged-inspect.json'); p=js('privileged-diag.json'); o=js('ordinary-diag.json')
    assert x['HostConfig']['Privileged'] and p['ops']['mount']['ok'] and not o['ops']['mount']['ok']
    q=subprocess.run(['/usr/bin/docker','ps','-q','--filter','status=running'],capture_output=True,text=True,check=True)
    for cid in q.stdout.split():
        y=json.loads(subprocess.check_output(['/usr/bin/docker','inspect',cid]))[0]
        assert not y['HostConfig']['Privileged'], f'Оставлен privileged-контейнер {y["Name"]}'
elif step=='10':
    x=inspect('hardened-final-inspect.json'); need('hardened-health.txt')
    h=x['HostConfig']; assert x['Config']['User']=='10001:10001' and h['ReadonlyRootfs'] and h['CapDrop']==['ALL']
    assert any('no-new-privileges' in str(v) for v in h['SecurityOpt']) and x['State']['Running']
    assert status('hardened-status.txt','Seccomp') == '2'
    assert need('hardened-health.txt').read_text().strip()=='ok'
else: raise SystemExit(2)
print(f'Шаг {step}: проверка пройдена')
