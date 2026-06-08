import logging
import os
import time
import uuid

import psycopg
from flask import Flask, jsonify, request

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("web-api-db")


def connection():
    return psycopg.connect(
        host=os.environ.get("DB_HOST", "db"),
        dbname=os.environ.get("DB_NAME", "app"),
        user=os.environ.get("DB_USER", "app"),
        password=os.environ.get("DB_PASSWORD", "lab-password"),
    )


@app.before_request
def start_request():
    request.request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    log.info("request-start request-id=%s endpoint=%s", request.request_id, request.path)


@app.after_request
def finish_request(response):
    response.headers["X-Request-ID"] = request.request_id
    log.info(
        "request-finish request-id=%s endpoint=%s status=%s",
        request.request_id,
        request.path,
        response.status_code,
    )
    return response


@app.get("/health")
def health():
    return jsonify(status="ok", service="api")


@app.get("/api/items")
def items():
    marker = request.request_id.replace("*", "")
    with connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                f"SELECT id, name FROM (VALUES (1, 'vm'), (2, 'container')) AS items(id, name) "
                f"/* request-id={marker} endpoint=/api/items */"
            )
            rows = [{"id": row[0], "name": row[1]} for row in cur.fetchall()]
    return jsonify(items=rows, request_id=request.request_id)


@app.get("/api/load")
def load():
    duration = min(float(request.args.get("seconds", "0.05")), 1.0)
    deadline = time.monotonic() + duration
    value = 0
    while time.monotonic() < deadline:
        value = (value * 33 + 17) % 1000003
    return jsonify(status="complete", value=value, request_id=request.request_id)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
