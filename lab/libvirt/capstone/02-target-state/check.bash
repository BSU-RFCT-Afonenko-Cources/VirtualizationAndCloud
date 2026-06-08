#!/usr/bin/env bash
set -euo pipefail
VIRSH=(/usr/bin/sudo -n /usr/bin/virsh -c qemu:///system)
virsh(){ "${VIRSH[@]}" "$@"; }
fail(){ /usr/bin/printf 'Ошибка: %s\n' "$1" >&2; exit 1; }
need_file(){ /usr/bin/test -s "$1" || fail "нет непустого файла $1"; }
F=/home/ubuntu/capstone/02-target-state/target-state.json; need_file "$F"
/usr/bin/python3 - "$F" <<'PY2'
import json,sys
x=json.load(open(sys.argv[1])); blob=json.dumps(x)
required=['cap-edge','cap-app','cap-db','cap-front','cap-back','capstone-pool','cap-edge.qcow2','cap-app.qcow2','cap-db.qcow2','cap-db-data.qcow2','/health','/version','/orders']
missing=[v for v in required if v not in blob]
if missing: raise SystemExit('Ошибка: отсутствуют обязательные значения: '+', '.join(missing))
def walk(v):
 if isinstance(v,dict):
  for a,b in v.items(): yield from walk(b)
 elif isinstance(v,list):
  for a in v: yield from walk(a)
 elif isinstance(v,str): yield v
vals=list(walk(x))
bad=[v for v in vals if (v.startswith('cap') and not (v.startswith('cap-') or v.startswith('capstone-')))]
infra=[v for v in vals if (v.endswith('.qcow2') or 'pool' in v.lower() or v.endswith('-net'))]
infra += [v for v in vals if v in ('edge','app','db','front','back')]
extra=[v for v in infra if v not in required and not (v.startswith('cap-') or v.startswith('capstone-'))]
if bad or extra: raise SystemExit('Ошибка: нарушен namespace: '+', '.join(sorted(set(bad+extra))))
PY2
