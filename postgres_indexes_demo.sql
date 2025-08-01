-- PostgreSQL Indexes Comprehensive Guide with Examples
-- This file demonstrates how indexes work in PostgreSQL

-- ====================================
-- 1. WHAT ARE INDEXES?
-- ====================================

/*
An index is a data structure that improves the speed of data retrieval operations 
on a database table. Think of it like an index in a book - instead of reading 
every page to find a topic, you use the index to jump directly to the right page.

Without an index: PostgreSQL must scan every row (Sequential Scan)
With an index: PostgreSQL can quickly locate specific rows (Index Scan)
*/

-- ====================================
-- 2. CREATING SAMPLE DATA
-- ====================================

-- Drop tables if they exist (for demo purposes)
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS sales CASCADE;

-- Create departments table
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(100)
);

-- Create employees table
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    dept_id INTEGER REFERENCES departments(dept_id),
    salary DECIMAL(10,2),
    hire_date DATE,
    age INTEGER,
    city VARCHAR(50)
);

-- Create sales table for demonstrating composite indexes
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    emp_id INTEGER REFERENCES employees(emp_id),
    product_name VARCHAR(100),
    sale_amount DECIMAL(10,2),
    sale_date DATE,
    region VARCHAR(50)
);

-- Insert sample departments
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'San Francisco'),
('Marketing', 'New York'),
('Sales', 'Chicago'),
('HR', 'Austin'),
('Finance', 'Boston');

-- Insert sample employees (larger dataset to demonstrate index benefits)
INSERT INTO employees (first_name, last_name, email, dept_id, salary, hire_date, age, city) VALUES
('John', 'Doe', 'john.doe@company.com', 1, 85000, '2020-01-15', 30, 'San Francisco'),
('Jane', 'Smith', 'jane.smith@company.com', 2, 75000, '2019-03-20', 28, 'New York'),
('Mike', 'Johnson', 'mike.johnson@company.com', 3, 65000, '2021-06-10', 32, 'Chicago'),
('Sarah', 'Williams', 'sarah.williams@company.com', 1, 90000, '2018-09-05', 35, 'San Francisco'),
('Tom', 'Brown', 'tom.brown@company.com', 4, 55000, '2022-02-14', 26, 'Austin'),
('Lisa', 'Davis', 'lisa.davis@company.com', 5, 70000, '2020-11-30', 29, 'Boston'),
('Robert', 'Miller', 'robert.miller@company.com', 1, 95000, '2017-04-18', 38, 'San Francisco'),
('Emily', 'Wilson', 'emily.wilson@company.com', 2, 68000, '2021-08-22', 27, 'New York'),
('David', 'Moore', 'david.moore@company.com', 3, 72000, '2019-12-03', 31, 'Chicago'),
('Amanda', 'Taylor', 'amanda.taylor@company.com', 1, 88000, '2020-07-11', 33, 'San Francisco');

-- Let's add more employees to better demonstrate index performance
INSERT INTO employees (first_name, last_name, email, dept_id, salary, hire_date, age, city)
SELECT 
    'Employee' || generate_series,
    'LastName' || generate_series,
    'emp' || generate_series || '@company.com',
    (generate_series % 5) + 1,
    50000 + (generate_series % 50000),
    '2020-01-01'::date + (generate_series % 1000),
    25 + (generate_series % 15),
    CASE (generate_series % 5)
        WHEN 0 THEN 'San Francisco'
        WHEN 1 THEN 'New York'
        WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Austin'
        ELSE 'Boston'
    END
FROM generate_series(1, 10000);

-- Insert sample sales data
INSERT INTO sales (emp_id, product_name, sale_amount, sale_date, region)
SELECT 
    (random() * 10000 + 1)::INTEGER,
    'Product' || (random() * 100 + 1)::INTEGER,
    (random() * 10000 + 100)::DECIMAL(10,2),
    '2023-01-01'::date + (random() * 365)::INTEGER,
    CASE (random() * 4)::INTEGER
        WHEN 0 THEN 'North'
        WHEN 1 THEN 'South'
        WHEN 2 THEN 'East'
        ELSE 'West'
    END
FROM generate_series(1, 50000);

-- ====================================
-- 3. UNDERSTANDING QUERY EXECUTION PLANS
-- ====================================

/*
Before creating indexes, let's see how PostgreSQL executes queries without them.
EXPLAIN ANALYZE shows the actual execution plan and timing.
*/

-- Check current query performance WITHOUT indexes (except primary keys)
EXPLAIN ANALYZE
SELECT * FROM employees WHERE last_name = 'Smith';

EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 80000;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE hire_date BETWEEN '2020-01-01' AND '2020-12-31';

-- ====================================
-- 4. TYPES OF INDEXES WITH EXAMPLES
-- ====================================

-- 4.1 B-Tree Index (Default and most common)
-- Best for equality and range queries

-- Create a B-tree index on last_name
CREATE INDEX idx_employees_last_name ON employees(last_name);

-- Now test the same query with index
EXPLAIN ANALYZE
SELECT * FROM employees WHERE last_name = 'Smith';

-- Create index on salary for range queries
CREATE INDEX idx_employees_salary ON employees(salary);

EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 80000;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary BETWEEN 70000 AND 90000;

-- 4.2 Composite Index (Multiple columns)
-- Useful when you frequently query on multiple columns together

CREATE INDEX idx_employees_dept_salary ON employees(dept_id, salary);

-- This query will benefit from the composite index
EXPLAIN ANALYZE
SELECT * FROM employees WHERE dept_id = 1 AND salary > 80000;

-- Note: Order matters in composite indexes!
-- idx_employees_dept_salary(dept_id, salary) can be used for:
-- - dept_id only
-- - dept_id AND salary
-- But NOT for salary only efficiently

-- 4.3 Partial Index
-- Index only rows that meet certain conditions

CREATE INDEX idx_employees_high_salary ON employees(last_name) 
WHERE salary > 80000;

-- This query benefits from the partial index
EXPLAIN ANALYZE
SELECT * FROM employees WHERE last_name = 'Johnson' AND salary > 80000;

-- 4.4 Hash Index
-- Best for equality comparisons only (not ranges)

CREATE INDEX idx_employees_city_hash ON employees USING HASH(city);

EXPLAIN ANALYZE
SELECT * FROM employees WHERE city = 'San Francisco';

-- 4.5 GIN Index (Generalized Inverted Index)
-- Excellent for array, JSON, and full-text search

-- Add a skills column to demonstrate GIN index
ALTER TABLE employees ADD COLUMN skills TEXT[];

-- Update some employees with skills
UPDATE employees SET skills = ARRAY['PostgreSQL', 'Python', 'JavaScript'] WHERE emp_id <= 100;
UPDATE employees SET skills = ARRAY['Java', 'Spring', 'Hibernate'] WHERE emp_id BETWEEN 101 AND 200;
UPDATE employees SET skills = ARRAY['React', 'Node.js', 'MongoDB'] WHERE emp_id BETWEEN 201 AND 300;

-- Create GIN index for array searches
CREATE INDEX idx_employees_skills_gin ON employees USING GIN(skills);

-- Query using array operators
EXPLAIN ANALYZE
SELECT * FROM employees WHERE skills @> ARRAY['PostgreSQL'];

EXPLAIN ANALYZE
SELECT * FROM employees WHERE 'Python' = ANY(skills);

-- 4.6 GIST Index (Generalized Search Tree)
-- Good for geometric data, ranges, and complex data types

-- Example with date ranges (using tsrange for demonstration)
ALTER TABLE employees ADD COLUMN employment_period tsrange;

UPDATE employees SET employment_period = tsrange(hire_date::timestamp, 
    CASE WHEN random() > 0.8 THEN (hire_date + interval '2 years')::timestamp ELSE NULL END);

CREATE INDEX idx_employees_period_gist ON employees USING GIST(employment_period);

-- ====================================
-- 5. INDEX MAINTENANCE AND MONITORING
-- ====================================

-- 5.1 View all indexes on a table
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'employees';

-- 5.2 Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as "Index Scans",
    idx_tup_read as "Tuples Read",
    idx_tup_fetch as "Tuples Fetched"
FROM pg_stat_user_indexes 
WHERE tablename = 'employees';

-- 5.3 Check table and index sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::regclass)) as "Total Size",
    pg_size_pretty(pg_relation_size(tablename::regclass)) as "Table Size"
FROM pg_tables 
WHERE tablename IN ('employees', 'sales', 'departments');

-- Index sizes
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as "Index Size"
FROM pg_indexes 
WHERE tablename = 'employees';

-- ====================================
-- 6. QUERY OPTIMIZATION EXAMPLES
-- ====================================

-- 6.1 JOIN operations with indexes
CREATE INDEX idx_sales_emp_id ON sales(emp_id);
CREATE INDEX idx_sales_date ON sales(sale_date);

-- Efficient JOIN query
EXPLAIN ANALYZE
SELECT 
    e.first_name,
    e.last_name,
    d.dept_name,
    s.sale_amount
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN sales s ON e.emp_id = s.emp_id
WHERE s.sale_date >= '2023-06-01'
  AND e.salary > 70000;

-- 6.2 Covering index (includes all needed columns)
CREATE INDEX idx_employees_covering ON employees(dept_id) INCLUDE (first_name, last_name, salary);

-- This query can be satisfied entirely from the index
EXPLAIN ANALYZE
SELECT first_name, last_name, salary 
FROM employees 
WHERE dept_id = 1;

-- ====================================
-- 7. COMMON INDEX PITFALLS AND BEST PRACTICES
-- ====================================

/*
WHEN TO USE INDEXES:
✓ Columns frequently used in WHERE clauses
✓ Columns used in JOIN conditions
✓ Columns used in ORDER BY
✓ Foreign key columns
✓ Columns with high selectivity (many unique values)

WHEN NOT TO USE INDEXES:
✗ Small tables (< 1000 rows typically)
✗ Columns that are frequently updated
✗ Columns with low selectivity (few unique values)
✗ Tables with high INSERT/UPDATE/DELETE activity

INDEX MAINTENANCE:
- Indexes slow down INSERT, UPDATE, DELETE operations
- They consume additional storage space
- They need to be maintained and can become fragmented
*/

-- 7.1 Demonstrate index impact on INSERT performance
-- Time without index on a new column
ALTER TABLE employees ADD COLUMN performance_score INTEGER;

-- Time many inserts
\timing on
UPDATE employees SET performance_score = (random() * 100)::INTEGER;
\timing off

-- Now add index and time the same operation
CREATE INDEX idx_employees_performance ON employees(performance_score);

\timing on
UPDATE employees SET performance_score = (random() * 100)::INTEGER;
\timing off

-- ====================================
-- 8. ADVANCED INDEX TECHNIQUES
-- ====================================

-- 8.1 Expression Index
-- Index on computed values or function results

CREATE INDEX idx_employees_full_name ON employees(LOWER(first_name || ' ' || last_name));

EXPLAIN ANALYZE
SELECT * FROM employees 
WHERE LOWER(first_name || ' ' || last_name) = 'john doe';

-- 8.2 Conditional Index with complex conditions
CREATE INDEX idx_recent_high_performers ON employees(salary) 
WHERE hire_date > '2020-01-01' AND performance_score > 80;

-- 8.3 Multi-column index for sorting
CREATE INDEX idx_employees_dept_salary_name ON employees(dept_id, salary DESC, last_name);

EXPLAIN ANALYZE
SELECT * FROM employees 
WHERE dept_id = 1 
ORDER BY salary DESC, last_name;

-- ====================================
-- 9. INDEX MONITORING AND CLEANUP
-- ====================================

-- Find unused indexes (be careful with this in production!)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_stat_user_indexes 
WHERE idx_scan = 0 
  AND tablename = 'employees';

-- Reindex if needed (rebuilds index to remove bloat)
-- REINDEX INDEX idx_employees_last_name;

-- Drop unused indexes (example - don't run automatically)
-- DROP INDEX IF EXISTS idx_employees_performance;

-- ====================================
-- 10. SUMMARY QUERIES FOR TESTING
-- ====================================

-- Test various index types with real queries
SELECT 'B-Tree Index Test' as test_type;
EXPLAIN ANALYZE SELECT * FROM employees WHERE last_name = 'Johnson';

SELECT 'Composite Index Test' as test_type;
EXPLAIN ANALYZE SELECT * FROM employees WHERE dept_id = 1 AND salary > 80000;

SELECT 'Partial Index Test' as test_type;
EXPLAIN ANALYZE SELECT * FROM employees WHERE last_name = 'Smith' AND salary > 80000;

SELECT 'Hash Index Test' as test_type;
EXPLAIN ANALYZE SELECT * FROM employees WHERE city = 'Chicago';

SELECT 'GIN Index Test' as test_type;
EXPLAIN ANALYZE SELECT * FROM employees WHERE skills @> ARRAY['PostgreSQL'];

-- Final statistics
SELECT 
    'Total Employees' as metric, 
    COUNT(*) as value 
FROM employees
UNION ALL
SELECT 
    'Total Sales Records' as metric, 
    COUNT(*) as value 
FROM sales
UNION ALL
SELECT 
    'Indexes on employees table' as metric, 
    COUNT(*) as value 
FROM pg_indexes 
WHERE tablename = 'employees';