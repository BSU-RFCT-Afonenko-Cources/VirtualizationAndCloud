import os
import time
from flask import Flask, jsonify, request
import psycopg

app = Flask(__name__)
VERSION = "1.0.0"

def connect():
    return psycopg.connect(
        host=os.environ.get("DB_HOST", "db"),
        dbname=os.environ.get("DB_NAME", "orders"),
        user=os.environ.get("DB_USER", "platform"),
        password=open(os.environ.get("DB_PASSWORD_FILE", "/run/secrets/db_password"), encoding="utf-8").read().strip(),
    )

def wait_for_db():
    for _ in range(60):
        try:
            with connect() as conn:
                conn.execute("SELECT 1")
            return
        except Exception:
            time.sleep(1)
    raise RuntimeError("database is unavailable")

@app.get("/health")
def health():
    try:
        with connect() as conn:
            conn.execute("SELECT 1")
        return jsonify(status="ok")
    except Exception as exc:
        return jsonify(status="error", detail=str(exc)), 503

@app.get("/version")
def version():
    return jsonify(service="orders-api", version=VERSION)

@app.post("/orders")
def create_order():
    body = request.get_json(force=True)
    sku = str(body.get("sku", "")).strip()
    quantity = int(body.get("quantity", 0))
    if not sku or quantity < 1:
        return jsonify(error="sku and positive quantity are required"), 400
    with connect() as conn:
        row = conn.execute(
            "INSERT INTO orders (sku, quantity, status) VALUES (%s, %s, 'queued') RETURNING id, sku, quantity, status",
            (sku, quantity),
        ).fetchone()
    return jsonify(id=row[0], sku=row[1], quantity=row[2], status=row[3]), 201

@app.get("/orders/<int:order_id>")
def get_order(order_id):
    with connect() as conn:
        row = conn.execute(
            "SELECT id, sku, quantity, status FROM orders WHERE id=%s", (order_id,)
        ).fetchone()
    if row is None:
        return jsonify(error="not found"), 404
    return jsonify(id=row[0], sku=row[1], quantity=row[2], status=row[3])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
