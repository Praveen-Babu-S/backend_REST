# PostgreSQL Indexes: Complete Guide with Examples

## Table of Contents
1. [What Are Indexes?](#what-are-indexes)
2. [How Indexes Work](#how-indexes-work)
3. [Types of Indexes](#types-of-indexes)
4. [When to Use Indexes](#when-to-use-indexes)
5. [Performance Impact](#performance-impact)
6. [Best Practices](#best-practices)
7. [Practical Examples](#practical-examples)

## What Are Indexes?

An **index** in PostgreSQL is a separate data structure that provides fast access paths to table data. Think of it like an index in a book:

- **Without an index**: You read every page to find a topic (Sequential Scan)
- **With an index**: You look up the topic in the index and jump directly to the right page (Index Scan)

### Real-World Analogy
Imagine you have a library with 10,000 books:
- **Without catalog**: You check every book to find "PostgreSQL Database"
- **With catalog**: You look up "PostgreSQL" in the catalog and go directly to shelf 15, row 3

## How Indexes Work

### 1. Storage Structure
```
Table Data (Heap):
Row 1: [ID=1001, Name="John", Salary=85000]
Row 2: [ID=1002, Name="Jane", Salary=75000]
Row 3: [ID=1003, Name="Mike", Salary=65000]
...

Index on Salary (B-Tree):
    75000 → Row 2
    65000 → Row 3
    85000 → Row 1
```

### 2. Query Execution Process

**Without Index:**
```sql
SELECT * FROM employees WHERE salary = 75000;
```
- PostgreSQL scans every row (Sequential Scan)
- Time complexity: O(n)
- For 10,000 rows: checks all 10,000 rows

**With Index:**
```sql
-- Same query with index
SELECT * FROM employees WHERE salary = 75000;
```
- PostgreSQL uses index to find matching rows (Index Scan)
- Time complexity: O(log n)
- For 10,000 rows: checks ~13 index nodes

## Types of Indexes

### 1. B-Tree Index (Default)
**Best for:** Equality and range queries

```sql
-- Create B-tree index
CREATE INDEX idx_salary ON employees(salary);

-- Efficient queries
SELECT * FROM employees WHERE salary = 75000;        -- Equality
SELECT * FROM employees WHERE salary > 70000;        -- Range
SELECT * FROM employees WHERE salary BETWEEN 70000 AND 90000;  -- Range
```

**Visual Representation:**
```
       [75000]
      /       \
  [65000]     [85000, 90000]
  /     \     /      |      \
[60K] [70K] [80K]  [85K]   [95K]
```

### 2. Hash Index
**Best for:** Equality comparisons only

```sql
-- Create hash index
CREATE INDEX idx_city_hash ON employees USING HASH(city);

-- Efficient query
SELECT * FROM employees WHERE city = 'San Francisco';  -- Equality only

-- NOT efficient
SELECT * FROM employees WHERE city > 'S';  -- Range queries don't work
```

### 3. GIN (Generalized Inverted Index)
**Best for:** Array, JSON, and full-text search

```sql
-- Add array column
ALTER TABLE employees ADD COLUMN skills TEXT[];

-- Create GIN index
CREATE INDEX idx_skills_gin ON employees USING GIN(skills);

-- Efficient queries
SELECT * FROM employees WHERE skills @> ARRAY['PostgreSQL'];  -- Contains
SELECT * FROM employees WHERE 'Python' = ANY(skills);        -- Any element
```

### 4. GIST (Generalized Search Tree)
**Best for:** Geometric data, ranges, complex types

```sql
-- Example with geometric data
CREATE INDEX idx_location_gist ON stores USING GIST(location);

-- Efficient for geometric queries
SELECT * FROM stores WHERE location <-> point(40.7, -74.0) < 1000;
```

### 5. Composite Index
**Best for:** Queries on multiple columns

```sql
-- Create composite index
CREATE INDEX idx_dept_salary ON employees(dept_id, salary);

-- Efficient queries (order matters!)
SELECT * FROM employees WHERE dept_id = 1;                    -- Uses index
SELECT * FROM employees WHERE dept_id = 1 AND salary > 80000; -- Uses index
SELECT * FROM employees WHERE salary > 80000;                 -- Doesn't use index efficiently
```

**Index Usage Rules for Composite Indexes:**
- Index on (A, B, C) can be used for:
  - WHERE A = ?
  - WHERE A = ? AND B = ?
  - WHERE A = ? AND B = ? AND C = ?
- But NOT efficiently for:
  - WHERE B = ?
  - WHERE C = ?
  - WHERE B = ? AND C = ?

### 6. Partial Index
**Best for:** Indexing only specific rows

```sql
-- Index only high-salary employees
CREATE INDEX idx_high_salary ON employees(last_name) 
WHERE salary > 80000;

-- Efficient query
SELECT * FROM employees WHERE last_name = 'Smith' AND salary > 80000;
```

**Benefits:**
- Smaller index size
- Faster index maintenance
- More selective

## When to Use Indexes

### ✅ CREATE Indexes When:

1. **Frequent WHERE clauses**
   ```sql
   -- If you often query by email
   SELECT * FROM users WHERE email = 'john@example.com';
   CREATE INDEX idx_users_email ON users(email);
   ```

2. **JOIN conditions**
   ```sql
   -- For foreign key relationships
   CREATE INDEX idx_orders_customer_id ON orders(customer_id);
   ```

3. **ORDER BY clauses**
   ```sql
   -- If you often sort by date
   SELECT * FROM orders ORDER BY order_date DESC;
   CREATE INDEX idx_orders_date ON orders(order_date);
   ```

4. **High selectivity columns**
   ```sql
   -- Good: email (unique values)
   CREATE INDEX idx_users_email ON users(email);
   
   -- Good: customer_id (many different values)
   CREATE INDEX idx_orders_customer ON orders(customer_id);
   ```

### ❌ AVOID Indexes When:

1. **Small tables (< 1000 rows)**
   - Sequential scan is faster

2. **Low selectivity columns**
   ```sql
   -- Bad: gender (only 2-3 values)
   -- Bad: status (only few values like 'active', 'inactive')
   ```

3. **Frequently updated columns**
   ```sql
   -- Bad: last_login (updated constantly)
   -- Bad: view_count (incremented frequently)
   ```

4. **High INSERT/UPDATE activity tables**
   - Indexes slow down write operations

## Performance Impact

### Query Performance (READ operations)

**Without Index:**
```sql
-- Scans 10,000 rows
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Electronics';

-- Result: Seq Scan on products (cost=0.00..180.00 rows=2000 width=41) 
--         (actual time=0.234..3.456 rows=2000 loops=1)
```

**With Index:**
```sql
-- Uses index to find ~2000 rows directly
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Electronics';

-- Result: Index Scan using idx_category on products (cost=0.29..45.67 rows=2000 width=41)
--         (actual time=0.015..0.892 rows=2000 loops=1)
```

**Performance Improvement:** ~4x faster!

### Write Performance (INSERT/UPDATE/DELETE)

**Impact on INSERT:**
```sql
-- Without indexes: Fast insert
INSERT INTO products (name, category, price) VALUES ('New Product', 'Electronics', 199.99);
-- Time: 0.1ms

-- With 3 indexes: Slower insert (must update 3 indexes)
INSERT INTO products (name, category, price) VALUES ('New Product', 'Electronics', 199.99);
-- Time: 0.4ms
```

**Rule of Thumb:**
- Each additional index adds ~20-30% overhead to write operations
- But can improve read performance by 10x-1000x

## Best Practices

### 1. Monitor Index Usage
```sql
-- Check which indexes are actually used
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as "Times Used",
    idx_tup_read as "Tuples Read"
FROM pg_stat_user_indexes 
WHERE tablename = 'your_table'
ORDER BY idx_scan DESC;
```

### 2. Remove Unused Indexes
```sql
-- Find unused indexes
SELECT 
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_stat_user_indexes 
WHERE idx_scan = 0 
  AND tablename = 'your_table';

-- Drop if truly unused
DROP INDEX IF EXISTS unused_index_name;
```

### 3. Consider Covering Indexes
```sql
-- Instead of multiple queries requiring table lookups
CREATE INDEX idx_covering ON employees(dept_id) INCLUDE (first_name, last_name, salary);

-- This query only needs the index (no table access)
SELECT first_name, last_name, salary 
FROM employees 
WHERE dept_id = 1;
```

### 4. Use Expression Indexes for Computed Values
```sql
-- For case-insensitive searches
CREATE INDEX idx_email_lower ON users(LOWER(email));

SELECT * FROM users WHERE LOWER(email) = 'john@example.com';
```

### 5. Maintain Indexes
```sql
-- Rebuild fragmented indexes
REINDEX INDEX idx_name;

-- Or rebuild all indexes on a table
REINDEX TABLE table_name;
```

## Practical Examples

### Example 1: E-commerce Product Search

**Scenario:** Product catalog with 100,000 products

```sql
-- Without indexes - SLOW
SELECT * FROM products 
WHERE category = 'Electronics' 
  AND price BETWEEN 100 AND 500
  AND brand = 'Apple';
-- Sequential scan through all 100,000 products

-- With strategic indexes - FAST
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_brand ON products(brand);

-- Even better: Composite index
CREATE INDEX idx_products_search ON products(category, brand, price);
-- Now the same query scans only relevant products
```

### Example 2: User Activity Logs

**Scenario:** Billions of log entries, frequent queries by user and date

```sql
-- Table structure
CREATE TABLE activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER,
    action VARCHAR(50),
    created_at TIMESTAMP,
    ip_address INET
);

-- Strategic indexes
CREATE INDEX idx_logs_user_date ON activity_logs(user_id, created_at);
CREATE INDEX idx_logs_recent ON activity_logs(created_at) 
WHERE created_at > NOW() - INTERVAL '30 days';  -- Partial index for recent data

-- Efficient queries
SELECT * FROM activity_logs 
WHERE user_id = 12345 
  AND created_at >= '2024-01-01';
```

### Example 3: Social Media Posts

**Scenario:** Posts with tags, likes, and comments

```sql
-- Table with array column for tags
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    content TEXT,
    tags TEXT[],
    like_count INTEGER,
    created_at TIMESTAMP
);

-- Indexes for different query patterns
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_tags_gin ON posts USING GIN(tags);
CREATE INDEX idx_posts_popular ON posts(like_count) WHERE like_count > 100;
CREATE INDEX idx_posts_recent ON posts(created_at DESC);

-- Efficient tag search
SELECT * FROM posts WHERE tags @> ARRAY['postgresql', 'database'];

-- Efficient popular posts
SELECT * FROM posts WHERE like_count > 100 ORDER BY like_count DESC;
```

## Testing Your Understanding

Run the provided SQL files to see indexes in action:

1. **`simple_index_demo.sql`** - Basic demonstration
2. **`postgres_indexes_demo.sql`** - Comprehensive examples

Key things to observe:
- `EXPLAIN ANALYZE` output showing "Seq Scan" vs "Index Scan"
- Execution time differences
- Index sizes and maintenance overhead

## Summary

**Indexes are powerful tools that:**
- ✅ Dramatically speed up SELECT queries
- ✅ Enable efficient JOINs
- ✅ Support fast sorting (ORDER BY)
- ❌ Slow down INSERT/UPDATE/DELETE operations
- ❌ Consume additional storage space
- ❌ Require maintenance

**Key takeaway:** Use indexes strategically based on your query patterns, not just because you can!