-- Simple PostgreSQL Index Demonstration
-- Run these commands step by step to see indexes in action

-- Setup: Create a simple table with sample data
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    created_date DATE
);

-- Insert 10,000 sample products
INSERT INTO products (name, category, price, created_date)
SELECT 
    'Product ' || generate_series,
    CASE (generate_series % 5)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Books'
        WHEN 3 THEN 'Home & Garden'
        ELSE 'Sports'
    END,
    (random() * 1000 + 10)::DECIMAL(10,2),
    '2023-01-01'::date + (random() * 365)::INTEGER
FROM generate_series(1, 10000);

-- STEP 1: Query WITHOUT index (notice the Seq Scan)
EXPLAIN ANALYZE
SELECT * FROM products WHERE category = 'Electronics';

-- STEP 2: Create an index on category
CREATE INDEX idx_products_category ON products(category);

-- STEP 3: Same query WITH index (notice the Index Scan)
EXPLAIN ANALYZE
SELECT * FROM products WHERE category = 'Electronics';

-- STEP 4: Range query without index on price
EXPLAIN ANALYZE
SELECT * FROM products WHERE price BETWEEN 100 AND 200;

-- STEP 5: Create index on price
CREATE INDEX idx_products_price ON products(price);

-- STEP 6: Same range query with index
EXPLAIN ANALYZE
SELECT * FROM products WHERE price BETWEEN 100 AND 200;

-- STEP 7: Composite index example
CREATE INDEX idx_products_category_price ON products(category, price);

-- STEP 8: Query that benefits from composite index
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE category = 'Electronics' AND price > 500;

-- View all indexes on the table
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'products';

-- Check index sizes
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as "Index Size"
FROM pg_indexes 
WHERE tablename = 'products';