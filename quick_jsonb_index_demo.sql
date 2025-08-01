-- Quick JSONB Index Demonstration
-- Run this script in PostgreSQL to see JSONB indexing in action

-- Create a sample table with complex JSONB data
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_data JSONB NOT NULL
);

-- Insert sample data with nested structures and arrays
INSERT INTO user_profiles (user_data) VALUES 
('{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 28,
    "preferences": {
        "categories": ["electronics", "books"],
        "settings": {"theme": "dark", "notifications": true}
    },
    "purchase_history": [
        {"order_id": "ORD-001", "total": 299.99, "date": "2024-01-15"},
        {"order_id": "ORD-002", "total": 89.99, "date": "2024-02-10"}
    ],
    "location": {"country": "USA", "city": "San Francisco"}
}'),
('{
    "name": "Jane Smith", 
    "email": "jane@example.com",
    "age": 32,
    "preferences": {
        "categories": ["gaming", "software"],
        "settings": {"theme": "light", "notifications": false}
    },
    "purchase_history": [
        {"order_id": "ORD-003", "total": 159.99, "date": "2024-01-20"}
    ],
    "location": {"country": "Canada", "city": "Toronto"}
}');

-- Generate more test data (1000 users for better demo)
INSERT INTO user_profiles (user_data)
SELECT jsonb_build_object(
    'name', 'User ' || i,
    'email', 'user' || i || '@example.com',
    'age', 20 + (i % 50),
    'preferences', jsonb_build_object(
        'categories', CASE (i % 3) 
            WHEN 0 THEN '["electronics", "books"]'::jsonb
            WHEN 1 THEN '["gaming", "software"]'::jsonb 
            ELSE '["clothing", "home"]'::jsonb
        END,
        'settings', jsonb_build_object(
            'theme', CASE (i % 2) WHEN 0 THEN 'dark' ELSE 'light' END,
            'notifications', (i % 2) = 0
        )
    ),
    'location', jsonb_build_object(
        'country', CASE (i % 3) WHEN 0 THEN 'USA' WHEN 1 THEN 'Canada' ELSE 'UK' END,
        'city', 'City' || (i % 10)
    )
) as user_data
FROM generate_series(1, 1000) as i;

-- =============================================
-- PERFORMANCE TEST: BEFORE INDEXES
-- =============================================

\echo 'Testing query performance WITHOUT indexes...'

-- Test 1: Find user by email (nested field access)
\timing on
\echo 'Query 1: Find user by email'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF) 
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->>'email' = 'john@example.com';

-- Test 2: Find users by age range
\echo 'Query 2: Find users by age range'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE (user_data->>'age')::int BETWEEN 25 AND 30;

-- Test 3: Find users by category (array contains)
\echo 'Query 3: Find users interested in electronics'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics';

-- Test 4: Find users by location
\echo 'Query 4: Find users in USA'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->'location'->>'country' = 'USA';

\timing off

-- =============================================
-- CREATE INDEXES
-- =============================================

\echo 'Creating indexes...'

-- 1. GIN index for general JSONB querying
CREATE INDEX idx_user_data_gin ON user_profiles USING GIN (user_data);

-- 2. B-tree expression indexes for specific paths
CREATE INDEX idx_user_email ON user_profiles ((user_data->>'email'));
CREATE INDEX idx_user_age ON user_profiles (((user_data->>'age')::int));
CREATE INDEX idx_user_country ON user_profiles ((user_data->'location'->>'country'));

-- 3. Partial index for electronics enthusiasts
CREATE INDEX idx_electronics_users ON user_profiles 
USING GIN ((user_data->'preferences'->'categories'))
WHERE user_data->'preferences'->'categories' ? 'electronics';

-- Update table statistics
ANALYZE user_profiles;

-- =============================================
-- PERFORMANCE TEST: AFTER INDEXES
-- =============================================

\echo 'Testing query performance WITH indexes...'

\timing on

-- Same queries as before - now with indexes
\echo 'Query 1: Find user by email (now with B-tree index)'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF) 
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->>'email' = 'john@example.com';

\echo 'Query 2: Find users by age range (now with B-tree index)'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE (user_data->>'age')::int BETWEEN 25 AND 30;

\echo 'Query 3: Find users interested in electronics (now with GIN index)'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics';

\echo 'Query 4: Find users in USA (now with B-tree index)'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data->'location'->>'country' = 'USA';

\timing off

-- =============================================
-- DEMONSTRATE JSONB OPERATORS WITH INDEXES
-- =============================================

\echo 'Demonstrating JSONB operators with indexes...'

-- Containment operator (@>)
\echo 'Using @> containment operator:'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data @> '{"location": {"country": "USA"}}';

-- Key existence operator (?)
\echo 'Using ? key existence operator:'
EXPLAIN (ANALYZE, BUFFERS, SUMMARY OFF)
SELECT id, user_data->>'name' as name
FROM user_profiles 
WHERE user_data ? 'purchase_history';

-- =============================================
-- INDEX SIZE AND MAINTENANCE ANALYSIS
-- =============================================

\echo 'Index size analysis:'
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
    idx_scan as scans_performed,
    idx_tup_read as tuples_read
FROM pg_stat_user_indexes 
WHERE tablename = 'user_profiles'
ORDER BY pg_relation_size(indexrelid) DESC;

\echo 'Table size comparison:'
SELECT 
    pg_size_pretty(pg_relation_size('user_profiles')) as table_size,
    pg_size_pretty(pg_total_relation_size('user_profiles')) as total_with_indexes;

-- =============================================
-- WRITE PERFORMANCE DEMONSTRATION
-- =============================================

\echo 'Testing write performance with indexes...'

\timing on

\echo 'INSERT performance test:'
INSERT INTO user_profiles (user_data) VALUES ('{
    "name": "Test User",
    "email": "test@example.com", 
    "age": 25,
    "preferences": {"categories": ["test"], "settings": {"theme": "dark"}},
    "location": {"country": "Test", "city": "TestCity"}
}');

\echo 'UPDATE performance test:'
UPDATE user_profiles 
SET user_data = jsonb_set(user_data, '{preferences,settings,theme}', '"light"', true)
WHERE id = (SELECT MAX(id) FROM user_profiles);

\timing off

-- =============================================
-- CLEANUP
-- =============================================

\echo 'Summary: JSONB Index Types Created:'
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'user_profiles' 
  AND indexname != 'user_profiles_pkey';

-- Clean up (uncomment to remove test data)
-- DROP TABLE user_profiles CASCADE;