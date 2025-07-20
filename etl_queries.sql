CREATE TABLE raw_sales (
  id INTEGER,
  name TEXT,
  sales_amount REAL,
  region TEXT,
  date TEXT
);

CREATE TABLE staging_sales (
  id INTEGER,
  name TEXT,
  sales_amount REAL,
  region TEXT,
  date TEXT
);

CREATE TABLE clean_sales (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  sales_amount REAL CHECK(sales_amount >= 0),
  region TEXT,
  date DATE
);

INSERT INTO staging_sales
SELECT DISTINCT * FROM raw_sales
WHERE name IS NOT NULL AND sales_amount IS NOT NULL;

INSERT INTO clean_sales
SELECT * FROM staging_sales
WHERE id NOT IN (SELECT id FROM clean_sales);

CREATE TABLE audit_log (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  inserted_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  records_inserted INTEGER
);

INSERT INTO audit_log (records_inserted)
VALUES ((SELECT COUNT(*) FROM staging_sales));

CREATE TRIGGER log_after_insert
AFTER INSERT ON clean_sales
BEGIN
  INSERT INTO audit_log (records_inserted)
  VALUES (1);
END;


