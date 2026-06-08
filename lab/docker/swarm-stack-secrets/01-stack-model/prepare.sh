#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

mkdir -p /home/ubuntu/shop/config /home/ubuntu/shop/evidence /home/ubuntu/shop/src/api /home/ubuntu/shop/build
chown -R ubuntu:ubuntu /home/ubuntu/shop

if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  apt-get install -y docker.io curl python3
fi

systemctl enable --now docker >/dev/null 2>&1 || true
if ! docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -qx active; then
  docker swarm init --advertise-addr 127.0.0.1 >/dev/null 2>&1 || true
fi

cat > /home/ubuntu/shop/build/app.py <<'PY'
import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

import psycopg2
from psycopg2.extras import RealDictCursor

APP_IMAGE_VERSION = os.environ.get("APP_IMAGE_VERSION", "v1")
CONFIG_PATH = os.environ.get("APP_CONFIG", "/app/config.json")
SECRET_PATH = os.environ.get("DB_PASSWORD_FILE", "/run/secrets/db_password")
DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("DB_NAME", "shop")
DB_USER = os.environ.get("DB_USER", "shop_user")


def read_config():
    with open(CONFIG_PATH, "r", encoding="utf-8") as handle:
        return json.load(handle)


def read_password():
    with open(SECRET_PATH, "r", encoding="utf-8") as handle:
        return handle.read().strip()


def connect():
    return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=read_password())


def ensure_schema():
    last_error = None
    for _ in range(30):
        try:
            with connect() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        create table if not exists products (
                          code text primary key,
                          name text not null,
                          price integer not null check (price > 0)
                        )
                        """
                    )
            return
        except Exception as exc:  # retry while PostgreSQL starts
            last_error = exc
            time.sleep(2)
    raise last_error


def product(code):
    with connect() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("select code, name, price from products where code = %s", (code,))
            return cur.fetchone()


def upsert_product(item):
    code = str(item.get("code", "")).strip()
    name = str(item.get("name", "")).strip()
    price = int(item.get("price", 0))
    if not code or not name or price <= 0:
        raise ValueError("code, name and positive price are required")
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                insert into products(code, name, price) values (%s, %s, %s)
                on conflict (code) do update set name = excluded.name, price = excluded.price
                """,
                (code, name, price),
            )
    return product(code)


class Handler(BaseHTTPRequestHandler):
    server_version = "shop-api"

    def json_response(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
        self.send_response(status)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/health":
            self.json_response(200, {"status": "ok"})
            return
        if path == "/version":
            cfg = read_config()
            self.json_response(200, {"app": cfg.get("app"), "version": cfg.get("version", APP_IMAGE_VERSION), "image": APP_IMAGE_VERSION, "rotated": bool(cfg.get("rotated", False))})
            return
        if path.startswith("/products/"):
            item = product(path.rsplit("/", 1)[-1])
            if item is None:
                self.json_response(404, {"error": "not found"})
            else:
                self.json_response(200, dict(item))
            return
        self.json_response(404, {"error": "not found"})

    def do_POST(self):
        path = urlparse(self.path).path
        if path != "/products":
            self.json_response(404, {"error": "not found"})
            return
        length = int(self.headers.get("content-length", "0"))
        data = json.loads(self.rfile.read(length).decode("utf-8"))
        try:
            self.json_response(201, dict(upsert_product(data)))
        except Exception as exc:
            self.json_response(400, {"error": str(exc)})

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)


if __name__ == "__main__":
    ensure_schema()
    ThreadingHTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
PY

cat > /home/ubuntu/shop/build/Dockerfile <<'DOCKER'
FROM python:3.12-alpine
ARG APP_IMAGE_VERSION=v1
ENV APP_IMAGE_VERSION=${APP_IMAGE_VERSION} \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN apk add --no-cache libpq && pip install --no-cache-dir psycopg2-binary==2.9.9
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=6 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).read()"
CMD ["python", "/app/app.py"]
DOCKER

docker build --build-arg APP_IMAGE_VERSION=v1 -t shop-api:v1 /home/ubuntu/shop/build >/dev/null
docker build --build-arg APP_IMAGE_VERSION=v2 -t shop-api:v2 /home/ubuntu/shop/build >/dev/null
docker pull nginx:1.27-alpine >/dev/null
docker pull postgres:16-alpine >/dev/null

chown -R ubuntu:ubuntu /home/ubuntu/shop
