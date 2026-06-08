CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  sku TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  status TEXT NOT NULL CHECK (status IN ('queued', 'completed', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS inventory (
  sku TEXT PRIMARY KEY,
  available INTEGER NOT NULL CHECK (available >= 0)
);
INSERT INTO inventory (sku, available) VALUES ('BOOK-001', 100), ('LAPTOP-001', 10)
ON CONFLICT (sku) DO NOTHING;
