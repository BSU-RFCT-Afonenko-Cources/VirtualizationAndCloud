import os
import time
from flask import Flask, jsonify
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
    return jsonify(service="inventory-api", version=VERSION)

@app.get("/inventory/<sku>")
def inventory(sku):
    with connect() as conn:
        row = conn.execute("SELECT sku, available FROM inventory WHERE sku=%s", (sku,)).fetchone()
    if row is None:
        return jsonify(error="not found"), 404
    return jsonify(sku=row[0], available=row[1])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
