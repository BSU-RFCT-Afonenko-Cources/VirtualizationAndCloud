#!/usr/bin/env bash
set -euo pipefail
LAB=/home/ubuntu/capstone-process-hibernation
command -v docker >/dev/null || { echo "Docker не установлен"; exit 1; }
[[ "$(docker inspect -f '{{.State.Running}}' hib-worker 2>/dev/null)" == true ]] || { echo "Контейнер hib-worker не работает"; exit 1; }
PID=$(docker inspect -f '{{.State.Pid}}' hib-worker)
[[ -r "/proc/${PID}/status" ]] || { echo "PID контейнера не найден в /proc"; exit 1; }
python3 - "${LAB}/evidence/progress-before.json" "${LAB}/evidence/progress-after.json" <<'PY'
import json, pathlib, sys, urllib.request
before=json.loads(pathlib.Path(sys.argv[1]).read_text())
after=json.loads(pathlib.Path(sys.argv[2]).read_text())
now=json.load(urllib.request.urlopen('http://127.0.0.1:18080/hib-status', timeout=3))
assert before['instance_id']==after['instance_id']==now['instance_id'], 'instance_id должен совпадать'
assert int(after['progress'])>int(before['progress'])>=0, 'Нет доказательства монотонного прогресса'
assert int(now['progress'])>=int(after['progress']), 'Текущий progress меньше evidence'
print('Worker работает, endpoint доступен, progress монотонен')
PY
