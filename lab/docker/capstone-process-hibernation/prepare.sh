#!/usr/bin/env bash
set -euo pipefail
LAB_DIR=/home/ubuntu/capstone-process-hibernation
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ASSETS="${SCRIPT_DIR}/assets"
ASSET_SRC=/home/ubuntu/capstone-process-hibernation/assets
mkdir -p "${LAB_DIR}/src" "${LAB_DIR}/data" "${LAB_DIR}/evidence" "${LAB_DIR}/backups" "${LAB_DIR}/checkpoints" "${ASSET_SRC}"
cp "${SOURCE_ASSETS}/hib_worker.py" "${ASSET_SRC}/hib_worker.py"
cp "${SOURCE_ASSETS}/Dockerfile.hib" "${ASSET_SRC}/Dockerfile.hib"
cp "${SOURCE_ASSETS}/common.sh" "${ASSET_SRC}/common.sh"
cp "${ASSET_SRC}/hib_worker.py" "${LAB_DIR}/src/hib_worker.py"
python3 - <<'PY'
from pathlib import Path
p=Path('/home/ubuntu/capstone-process-hibernation/data/queue.txt')
if not p.exists():
    p.write_text('\n'.join(f'job-{i:05d}' for i in range(1,10001))+'\n', encoding='utf-8')
PY
cat > "${LAB_DIR}/README.txt" <<'TXT'
Рабочий каталог самостоятельной работы. Полезная нагрузка hib-worker находится в src/hib_worker.py; проектируйте workflow самостоятельно и сохраняйте evidence в evidence/.
TXT
chown -R ubuntu:ubuntu "${LAB_DIR}"
chmod -R a+rX "${ASSET_SRC}"
