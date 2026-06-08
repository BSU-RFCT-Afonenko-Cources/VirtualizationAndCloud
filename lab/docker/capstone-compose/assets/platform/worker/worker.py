import os
import time
import psycopg

PASSWORD_FILE = os.environ.get("DB_PASSWORD_FILE", "/run/secrets/db_password")

def connect():
    return psycopg.connect(
        host=os.environ.get("DB_HOST", "db"),
        dbname=os.environ.get("DB_NAME", "orders"),
        user=os.environ.get("DB_USER", "platform"),
        password=open(PASSWORD_FILE, encoding="utf-8").read().strip(),
    )

while True:
    try:
        with connect() as conn:
            row = conn.execute(
                "SELECT id, sku, quantity FROM orders WHERE status='queued' ORDER BY id FOR UPDATE SKIP LOCKED LIMIT 1"
            ).fetchone()
            if row:
                available = conn.execute("SELECT available FROM inventory WHERE sku=%s FOR UPDATE", (row[1],)).fetchone()
                status = "completed" if available and available[0] >= row[2] else "rejected"
                if status == "completed":
                    conn.execute("UPDATE inventory SET available=available-%s WHERE sku=%s", (row[2], row[1]))
                conn.execute("UPDATE orders SET status=%s WHERE id=%s", (status, row[0]))
                print(f"processed order={row[0]} status={status}", flush=True)
    except Exception as exc:
        print(f"worker retry: {exc}", flush=True)
    time.sleep(1)
