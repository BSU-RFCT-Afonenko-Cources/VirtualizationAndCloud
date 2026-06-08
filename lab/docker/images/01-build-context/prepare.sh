#!/usr/bin/env bash
set -euo pipefail

PROJECT=/home/ubuntu/image-lab
install -d -o ubuntu -g ubuntu "$PROJECT" "$PROJECT/__pycache__"
cat > "$PROJECT/app.py" <<'PY'
from pathlib import Path

from flask import Flask, jsonify

app = Flask(__name__)
version = Path("/app/VERSION").read_text(encoding="utf-8").strip()


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/version")
def get_version():
    return jsonify(version=version)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PY
printf '%s\n' 'Flask==3.1.1' > "$PROJECT/requirements.txt"
printf '%s\n' '1.0.0' > "$PROJECT/VERSION"
printf '%s\n' 'LOCAL_TOKEN=do-not-copy' > "$PROJECT/.env"
printf '%s\n' 'local debug output' > "$PROJECT/debug.log"
printf '%s\n' 'compiled-placeholder' > "$PROJECT/__pycache__/app.cpython-312.pyc"
rm -f "$PROJECT/.dockerignore"
chown -R ubuntu:ubuntu "$PROJECT"
