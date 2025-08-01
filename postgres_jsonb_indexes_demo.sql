-- PostgreSQL JSONB Indexes Demonstration
-- This file demonstrates how indexes work with JSONB data types and their performance implications

-- =============================================
-- 1. CREATE SAMPLE TABLE WITH COMPLEX JSONB DATA
-- =============================================

DROP TABLE IF EXISTS user_profiles CASCADE;

CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- 2. INSERT SAMPLE DATA WITH COMPLEX STRUCTURES
-- =============================================

-- Insert sample data with nested objects, arrays, and various field types
INSERT INTO user_profiles (user_data) VALUES 
-- User 1: E-commerce profile
('{
    "personal_info": {
        "name": "John Doe",
        "email": "john.doe@example.com",
        "age": 28,
        "location": {
            "country": "USA",
            "state": "California",
            "city": "San Francisco",
            "coordinates": {"lat": 37.7749, "lng": -122.4194}
        }
    },
    "preferences": {
        "categories": ["electronics", "books", "clothing"],
        "price_range": {"min": 10, "max": 500},
        "notifications": {
            "email": true,
            "sms": false,
            "push": true
        }
    },
    "purchase_history": [
        {
            "order_id": "ORD-001",
            "date": "2024-01-15",
            "total": 299.99,
            "items": [
                {"product_id": "PROD-123", "name": "Wireless Headphones", "price": 199.99},
                {"product_id": "PROD-456", "name": "Phone Case", "price": 29.99}
            ]
        },
        {
            "order_id": "ORD-002",
            "date": "2024-02-10",
            "total": 89.99,
            "items": [
                {"product_id": "PROD-789", "name": "Book: PostgreSQL Guide", "price": 89.99}
            ]
        }
    ],
    "metadata": {
        "account_created": "2023-12-01",
        "last_login": "2024-03-15T10:30:00Z",
        "session_count": 45,
        "device_info": {
            "platform": "web",
            "browser": "Chrome",
            "version": "121.0"
        }
    }
}'),

-- User 2: Gaming profile
('{
    "personal_info": {
        "name": "Jane Smith",
        "email": "jane.smith@example.com",
        "age": 24,
        "location": {
            "country": "Canada",
            "state": "Ontario",
            "city": "Toronto",
            "coordinates": {"lat": 43.6532, "lng": -79.3832}
        }
    },
    "preferences": {
        "categories": ["gaming", "electronics", "software"],
        "price_range": {"min": 5, "max": 200},
        "notifications": {
            "email": false,
            "sms": true,
            "push": true
        }
    },
    "purchase_history": [
        {
            "order_id": "ORD-003",
            "date": "2024-01-20",
            "total": 59.99,
            "items": [
                {"product_id": "PROD-321", "name": "Indie Game Bundle", "price": 59.99}
            ]
        }
    ],
    "metadata": {
        "account_created": "2024-01-01",
        "last_login": "2024-03-16T14:22:00Z",
        "session_count": 23,
        "device_info": {
            "platform": "mobile",
            "browser": "Safari",
            "version": "17.3"
        }
    }
}'),

-- User 3: Business profile
('{
    "personal_info": {
        "name": "Mike Johnson",
        "email": "mike.johnson@business.com",
        "age": 35,
        "location": {
            "country": "UK",
            "state": "England",
            "city": "London",
            "coordinates": {"lat": 51.5074, "lng": -0.1278}
        }
    },
    "preferences": {
        "categories": ["business", "software", "books"],
        "price_range": {"min": 50, "max": 1000},
        "notifications": {
            "email": true,
            "sms": true,
            "push": false
        }
    },
    "purchase_history": [
        {
            "order_id": "ORD-004",
            "date": "2024-02-05",
            "total": 599.99,
            "items": [
                {"product_id": "PROD-555", "name": "Business Software License", "price": 599.99}
            ]
        },
        {
            "order_id": "ORD-005",
            "date": "2024-03-01",
            "total": 149.99,
            "items": [
                {"product_id": "PROD-666", "name": "Project Management Book", "price": 45.99},
                {"product_id": "PROD-777", "name": "Enterprise Tools", "price": 104.00}
            ]
        }
    ],
    "metadata": {
        "account_created": "2023-11-15",
        "last_login": "2024-03-16T09:15:00Z",
        "session_count": 78,
        "device_info": {
            "platform": "desktop",
            "browser": "Firefox",
            "version": "123.0"
        }
    }
}');

-- Generate more test data (simulate 10,000 users)
INSERT INTO user_profiles (user_data)
SELECT jsonb_build_object(
    'personal_info', jsonb_build_object(
        'name', 'User ' || i,
        'email', 'user' || i || '@example.com',
        'age', 20 + (i % 50),
        'location', jsonb_build_object(
            'country', CASE (i % 3) WHEN 0 THEN 'USA' WHEN 1 THEN 'Canada' ELSE 'UK' END,
            'city', CASE (i % 3) WHEN 0 THEN 'New York' WHEN 1 THEN 'Vancouver' ELSE 'Manchester' END,
            'coordinates', jsonb_build_object('lat', 40.7128 + (i % 100) * 0.01, 'lng', -74.0060 + (i % 100) * 0.01)
        )
    ),
    'preferences', jsonb_build_object(
        'categories', CASE (i % 4) 
            WHEN 0 THEN '["electronics", "books"]'::jsonb
            WHEN 1 THEN '["gaming", "software"]'::jsonb 
            WHEN 2 THEN '["clothing", "home"]'::jsonb
            ELSE '["business", "tools"]'::jsonb
        END,
        'price_range', jsonb_build_object('min', (i % 5) * 10, 'max', 100 + (i % 10) * 50)
    ),
    'metadata', jsonb_build_object(
        'session_count', i % 100,
        'account_created', '2023-01-01'::date + (i % 365) * interval '1 day',
        'device_info', jsonb_build_object(
            'platform', CASE (i % 3) WHEN 0 THEN 'web' WHEN 1 THEN 'mobile' ELSE 'desktop' END
        )
    )
) as user_data
FROM generate_series(1, 10000) as i;

-- =============================================
-- 3. QUERY PERFORMANCE WITHOUT INDEXES
-- =============================================

-- Enable timing to see execution times
\timing on

-- Query 1: Find users by email (nested field)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'personal_info'->>'email' = 'john.doe@example.com';

-- Query 2: Find users by age range
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE (user_data->'personal_info'->>'age')::int BETWEEN 25 AND 30;

-- Query 3: Find users by category preference (array contains)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics';

-- Query 4: Find users by location (nested object)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'personal_info'->'location'->>'country' = 'USA';

-- Query 5: Complex query with multiple JSONB conditions
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics'
  AND (user_data->'metadata'->>'session_count')::int > 50
  AND user_data->'personal_info'->'location'->>'country' = 'USA';

-- =============================================
-- 4. CREATE DIFFERENT TYPES OF JSONB INDEXES
-- =============================================

-- 4.1 GIN Index on entire JSONB column (default operator class)
CREATE INDEX idx_user_data_gin ON user_profiles USING GIN (user_data);

-- 4.2 GIN Index with jsonb_path_ops (more efficient for containment)
CREATE INDEX idx_user_data_gin_path_ops ON user_profiles USING GIN (user_data jsonb_path_ops);

-- 4.3 B-tree indexes on specific JSONB paths (expression indexes)
CREATE INDEX idx_email ON user_profiles ((user_data->'personal_info'->>'email'));
CREATE INDEX idx_age ON user_profiles (((user_data->'personal_info'->>'age')::int));
CREATE INDEX idx_country ON user_profiles ((user_data->'personal_info'->'location'->>'country'));
CREATE INDEX idx_session_count ON user_profiles (((user_data->'metadata'->>'session_count')::int));

-- 4.4 Partial indexes for specific conditions
CREATE INDEX idx_electronics_users ON user_profiles 
USING GIN ((user_data->'preferences'->'categories'))
WHERE user_data->'preferences'->'categories' ? 'electronics';

-- 4.5 Composite expression index
CREATE INDEX idx_country_age ON user_profiles (
    (user_data->'personal_info'->'location'->>'country'),
    ((user_data->'personal_info'->>'age')::int)
);

-- =============================================
-- 5. QUERY PERFORMANCE WITH INDEXES
-- =============================================

-- Analyze tables to update statistics
ANALYZE user_profiles;

EXPLAIN (ANALYZE, BUFFERS) 
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'personal_info'->>'email' = 'john.doe@example.com';

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE (user_data->'personal_info'->>'age')::int BETWEEN 25 AND 30;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics';

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'personal_info'->'location'->>'country' = 'USA';

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'preferences'->'categories' ? 'electronics'
  AND (user_data->'metadata'->>'session_count')::int > 50
  AND user_data->'personal_info'->'location'->>'country' = 'USA';

-- =============================================
-- 6. ADVANCED JSONB QUERIES AND INDEX USAGE
-- =============================================

-- Query with JSONB operators
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data @> '{"preferences": {"categories": ["electronics"]}}';

-- Query with path existence
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data ? 'purchase_history';

-- Query with nested containment
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_data->'personal_info'->>'name' as name
FROM user_profiles 
WHERE user_data->'personal_info' @> '{"location": {"country": "USA"}}';

-- =============================================
-- 7. INDEX SIZE AND MAINTENANCE ANALYSIS
-- =============================================

-- Check index sizes
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE tablename = 'user_profiles'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check table size
SELECT pg_size_pretty(pg_total_relation_size('user_profiles')) as total_size,
       pg_size_pretty(pg_relation_size('user_profiles')) as table_size;

-- =============================================
-- 8. UPDATE PERFORMANCE WITH INDEXES
-- =============================================

-- Test update performance (this will show the cost of maintaining indexes)
EXPLAIN (ANALYZE, BUFFERS)
UPDATE user_profiles 
SET user_data = jsonb_set(user_data, '{metadata,last_login}', '"2024-03-17T10:00:00Z"', true)
WHERE id = 1;

-- Test insert performance
EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO user_profiles (user_data) VALUES ('{
    "personal_info": {
        "name": "Test User",
        "email": "test@example.com",
        "age": 30,
        "location": {"country": "Germany", "city": "Berlin"}
    },
    "preferences": {
        "categories": ["electronics", "software"],
        "price_range": {"min": 20, "max": 300}
    },
    "metadata": {
        "session_count": 5,
        "account_created": "2024-03-17"
    }
}');

-- =============================================
-- 9. CLEANUP AND SUMMARY
-- =============================================

-- Show all indexes on the table
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'user_profiles';

\timing off