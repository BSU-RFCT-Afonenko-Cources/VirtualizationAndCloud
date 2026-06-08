#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Приводим persistent/runtime ресурсы ВМ к разным профилям и сохраняем JSON-инвентаризацию.
D=/home/ubuntu/capstone/11-resources; ensure_dir "$D"
for spec in 'cap-edge 1 524288' 'cap-app 2 1048576' 'cap-db 2 1572864'; do set -- $spec; vm=$1; cpu=$2; mem=$3; "${VIRSH[@]}" setvcpus "$vm" "$cpu" --config; "${VIRSH[@]}" setvcpus "$vm" "$cpu" --live || true; "${VIRSH[@]}" setmaxmem "$vm" "$mem" --config; "${VIRSH[@]}" setmem "$vm" "$mem" --config; "${VIRSH[@]}" setmem "$vm" "$mem" --live || true; done
/usr/bin/python3 - "$D/resources.json" <<'PY2'
import json,subprocess
out={}
for vm in ('cap-edge','cap-app','cap-db'):
 xml=subprocess.check_output(['sudo','-n','virsh','-c','qemu:///system','dumpxml',vm,'--config'],text=True)
 import xml.etree.ElementTree as E
 r=E.fromstring(xml); out[vm]={'vcpus':int(r.findtext('vcpu')),'memory_kib':int(r.findtext('memory')),'block_devices':[x.find('target').get('dev') for x in r.findall("./devices/disk[@device='disk']") if x.find('target') is not None]}
json.dump(out,open(__import__('sys').argv[1],'w'),indent=2)
PY2
/usr/bin/chown ubuntu:ubuntu "$D/resources.json"
