# SQL Database Normalization Rules: Complete Guide

## Table of Contents
1. [Introduction to Normalization](#introduction)
2. [First Normal Form (1NF)](#first-normal-form)
3. [Second Normal Form (2NF)](#second-normal-form)
4. [Third Normal Form (3NF)](#third-normal-form)
5. [Boyce-Codd Normal Form (BCNF)](#boyce-codd-normal-form)
6. [Fourth Normal Form (4NF)](#fourth-normal-form)
7. [Fifth Normal Form (5NF)](#fifth-normal-form)
8. [Sixth Normal Form (6NF)](#sixth-normal-form)
9. [Denormalization Considerations](#denormalization)
10. [Practical Examples](#practical-examples)
11. [Best Practices](#best-practices)

## Introduction to Normalization {#introduction}

Database normalization is the process of organizing data in a relational database to reduce redundancy and improve data integrity. It involves decomposing tables into smaller, related tables and defining relationships between them.

### Goals of Normalization
- **Eliminate Redundant Data**: Reduce storage space and inconsistencies
- **Ensure Data Integrity**: Prevent update, insertion, and deletion anomalies
- **Improve Data Consistency**: Maintain accuracy across related data
- **Facilitate Maintenance**: Make schema changes easier to implement

### Key Concepts
- **Functional Dependency**: X → Y means Y is functionally dependent on X
- **Candidate Key**: Minimal set of attributes that uniquely identifies a tuple
- **Primary Key**: Chosen candidate key for the relation
- **Partial Dependency**: Non-key attribute depends on part of a composite key
- **Transitive Dependency**: Non-key attribute depends on another non-key attribute

## First Normal Form (1NF) {#first-normal-form}

### Definition
A table is in 1NF if:
1. **Atomic Values**: Each column contains indivisible (atomic) values
2. **No Repeating Groups**: No repeating columns or arrays
3. **Unique Column Names**: Each column has a unique name
4. **Consistent Data Types**: Each column contains values of the same type

### Violation Example
```sql
-- VIOLATES 1NF: Multiple phone numbers in one column
CREATE TABLE customers_bad (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    phone_numbers VARCHAR(200), -- "123-456-7890, 098-765-4321, 555-123-4567"
    skills VARCHAR(300)          -- "Java, Python, SQL, JavaScript"
);
```

### 1NF Solution
```sql
-- COMPLIES WITH 1NF: Atomic values only
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE customer_phones (
    customer_id INT,
    phone_number VARCHAR(15),
    phone_type VARCHAR(20), -- 'mobile', 'home', 'work'
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE customer_skills (
    customer_id INT,
    skill VARCHAR(50),
    PRIMARY KEY (customer_id, skill),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Common 1NF Violations and Fixes

#### Multi-Value Attributes
```sql
-- WRONG: Multiple values in one field
CREATE TABLE orders_bad (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    products VARCHAR(500) -- "Laptop, Mouse, Keyboard"
);

-- CORRECT: Separate table for order items
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE
);

CREATE TABLE order_items (
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_name),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
```

#### Repeating Groups
```sql
-- WRONG: Repeating columns
CREATE TABLE students_bad (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    subject1 VARCHAR(50),
    grade1 CHAR(2),
    subject2 VARCHAR(50),
    grade2 CHAR(2),
    subject3 VARCHAR(50),
    grade3 CHAR(2)
);

-- CORRECT: Separate table for enrollments
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE enrollments (
    student_id INT,
    subject VARCHAR(50),
    grade CHAR(2),
    PRIMARY KEY (student_id, subject),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
```

## Second Normal Form (2NF) {#second-normal-form}

### Definition
A table is in 2NF if:
1. **Already in 1NF**
2. **No Partial Dependencies**: Every non-key attribute is fully functionally dependent on the entire primary key

**Note**: 2NF only applies to tables with composite primary keys.

### Violation Example
```sql
-- VIOLATES 2NF: Partial dependencies exist
CREATE TABLE order_details_bad (
    order_id INT,
    product_id INT,
    customer_name VARCHAR(100),    -- Depends only on order_id (partial dependency)
    product_name VARCHAR(100),     -- Depends only on product_id (partial dependency)
    product_price DECIMAL(10,2),   -- Depends only on product_id (partial dependency)
    quantity INT,                  -- Depends on both order_id and product_id (full dependency)
    PRIMARY KEY (order_id, product_id)
);
```

**Functional Dependencies:**
- `order_id → customer_name` (partial dependency)
- `product_id → product_name, product_price` (partial dependency)
- `order_id, product_id → quantity` (full dependency)

### 2NF Solution
```sql
-- COMPLIES WITH 2NF: Remove partial dependencies
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    product_price DECIMAL(10,2)
);

CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Benefits of 2NF
- **Eliminates Update Anomalies**: Changing product price only requires one update
- **Eliminates Insertion Anomalies**: Can add new products without requiring orders
- **Eliminates Deletion Anomalies**: Deleting an order doesn't lose product information

## Third Normal Form (3NF) {#third-normal-form}

### Definition
A table is in 3NF if:
1. **Already in 2NF**
2. **No Transitive Dependencies**: No non-key attribute depends on another non-key attribute

### Violation Example
```sql
-- VIOLATES 3NF: Transitive dependency exists
CREATE TABLE employees_bad (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),    -- Depends on department_id (transitive dependency)
    department_location VARCHAR(100), -- Depends on department_id (transitive dependency)
    salary DECIMAL(10,2)
);
```

**Functional Dependencies:**
- `employee_id → name, department_id, salary` (direct dependency)
- `department_id → department_name, department_location` (transitive dependency)

### 3NF Solution
```sql
-- COMPLIES WITH 3NF: Remove transitive dependencies
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_location VARCHAR(100)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

### Real-World 3NF Example
```sql
-- Before 3NF: Customer orders with redundant city/state info
CREATE TABLE customer_orders_bad (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    zip_code VARCHAR(10),
    city VARCHAR(50),           -- Depends on zip_code
    state VARCHAR(50),          -- Depends on zip_code
    order_total DECIMAL(10,2)
);

-- After 3NF: Separate location information
CREATE TABLE zip_codes (
    zip_code VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    zip_code VARCHAR(10),
    FOREIGN KEY (zip_code) REFERENCES zip_codes(zip_code)
);

CREATE TABLE customer_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

## Boyce-Codd Normal Form (BCNF) {#boyce-codd-normal-form}

### Definition
A table is in BCNF if:
1. **Already in 3NF**
2. **Every determinant is a candidate key**: For every functional dependency X → Y, X must be a superkey

BCNF is a stricter version of 3NF that handles certain anomalies that 3NF might miss.

### Violation Example
```sql
-- VIOLATES BCNF: Non-key attribute determines part of the key
CREATE TABLE course_instructors_bad (
    student_id INT,
    course VARCHAR(50),
    instructor VARCHAR(100),
    PRIMARY KEY (student_id, course)
);
```

**Functional Dependencies:**
- `student_id, course → instructor` (primary key dependency)
- `instructor → course` (violation: instructor is not a candidate key)

**Problem**: Each instructor teaches only one course, but instructor is not a candidate key.

### BCNF Solution
```sql
-- COMPLIES WITH BCNF: Separate instructor-course relationship
CREATE TABLE instructors (
    instructor VARCHAR(100) PRIMARY KEY,
    course VARCHAR(50)
);

CREATE TABLE enrollments (
    student_id INT,
    instructor VARCHAR(100),
    PRIMARY KEY (student_id, instructor),
    FOREIGN KEY (instructor) REFERENCES instructors(instructor)
);
```

### Another BCNF Example
```sql
-- Before BCNF: Room booking system
CREATE TABLE room_bookings_bad (
    room_number VARCHAR(10),
    time_slot VARCHAR(20),
    activity VARCHAR(50),
    instructor VARCHAR(100),
    PRIMARY KEY (room_number, time_slot)
);

-- Assumption: Each instructor can only conduct one activity
-- FD: instructor → activity (violates BCNF)

-- After BCNF:
CREATE TABLE instructor_activities (
    instructor VARCHAR(100) PRIMARY KEY,
    activity VARCHAR(50)
);

CREATE TABLE room_bookings (
    room_number VARCHAR(10),
    time_slot VARCHAR(20),
    instructor VARCHAR(100),
    PRIMARY KEY (room_number, time_slot),
    FOREIGN KEY (instructor) REFERENCES instructor_activities(instructor)
);
```

## Fourth Normal Form (4NF) {#fourth-normal-form}

### Definition
A table is in 4NF if:
1. **Already in BCNF**
2. **No Multi-Valued Dependencies (MVDs)**: For every MVD X ↠ Y, X is a superkey

Multi-Valued Dependency: X ↠ Y means that for each value of X, there is a set of values of Y, and this set is independent of other attributes.

### Violation Example
```sql
-- VIOLATES 4NF: Multi-valued dependencies
CREATE TABLE student_courses_hobbies_bad (
    student_id INT,
    course VARCHAR(50),
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, course, hobby)
);
```

**Multi-Valued Dependencies:**
- `student_id ↠ course` (student can take multiple courses)
- `student_id ↠ hobby` (student can have multiple hobbies)
- Courses and hobbies are independent of each other

**Problem**: Creates unnecessary combinations (Cartesian product of courses and hobbies for each student)

### 4NF Solution
```sql
-- COMPLIES WITH 4NF: Separate multi-valued dependencies
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE student_courses (
    student_id INT,
    course VARCHAR(50),
    PRIMARY KEY (student_id, course),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

CREATE TABLE student_hobbies (
    student_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
```

### Real-World 4NF Example
```sql
-- Before 4NF: Employee skills and languages
CREATE TABLE employee_skills_languages_bad (
    employee_id INT,
    skill VARCHAR(50),
    language VARCHAR(50),
    PRIMARY KEY (employee_id, skill, language)
);

-- Problems:
-- 1. If employee learns new skill, need to add rows for all languages
-- 2. If employee learns new language, need to add rows for all skills
-- 3. Unnecessary data redundancy

-- After 4NF:
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE employee_skills (
    employee_id INT,
    skill VARCHAR(50),
    proficiency_level VARCHAR(20),
    PRIMARY KEY (employee_id, skill),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE employee_languages (
    employee_id INT,
    language VARCHAR(50),
    fluency_level VARCHAR(20),
    PRIMARY KEY (employee_id, language),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

## Fifth Normal Form (5NF) {#fifth-normal-form}

### Definition
A table is in 5NF (also called Project-Join Normal Form - PJNF) if:
1. **Already in 4NF**
2. **No Join Dependencies**: Cannot be decomposed into smaller tables without losing information

Join Dependency: A table has a join dependency if it can be recreated by joining its projections.

### Violation Example
```sql
-- VIOLATES 5NF: Join dependency exists
CREATE TABLE supplier_part_project_bad (
    supplier VARCHAR(50),
    part VARCHAR(50),
    project VARCHAR(50),
    PRIMARY KEY (supplier, part, project)
);
```

**Business Rules:**
1. Suppliers can supply parts
2. Parts can be used in projects  
3. Suppliers can work on projects
4. A supplier supplies a part to a project only if:
   - The supplier can supply that part, AND
   - The part is used in that project, AND
   - The supplier works on that project

### 5NF Solution
```sql
-- COMPLIES WITH 5NF: Decompose join dependencies
CREATE TABLE supplier_parts (
    supplier VARCHAR(50),
    part VARCHAR(50),
    PRIMARY KEY (supplier, part)
);

CREATE TABLE part_projects (
    part VARCHAR(50),
    project VARCHAR(50),
    PRIMARY KEY (part, project)
);

CREATE TABLE supplier_projects (
    supplier VARCHAR(50),
    project VARCHAR(50),
    PRIMARY KEY (supplier, project)
);

-- The original table can be recreated by joining these three tables
-- This eliminates redundancy while preserving all information
```

### When 5NF Matters
```sql
-- Example: Academic database
-- Professors teach courses, courses have textbooks, professors recommend textbooks

-- Before 5NF: Redundant combinations
CREATE TABLE professor_course_textbook_bad (
    professor VARCHAR(100),
    course VARCHAR(50),
    textbook VARCHAR(200),
    PRIMARY KEY (professor, course, textbook)
);

-- After 5NF: Separate relationships
CREATE TABLE professor_courses (
    professor VARCHAR(100),
    course VARCHAR(50),
    PRIMARY KEY (professor, course)
);

CREATE TABLE course_textbooks (
    course VARCHAR(50),
    textbook VARCHAR(200),
    PRIMARY KEY (course, textbook)
);

CREATE TABLE professor_textbook_recommendations (
    professor VARCHAR(100),
    textbook VARCHAR(200),
    PRIMARY KEY (professor, textbook)
);
```

## Sixth Normal Form (6NF) {#sixth-normal-form}

### Definition
A table is in 6NF if:
1. **Already in 5NF**
2. **No Non-Trivial Join Dependencies**: The table cannot be further decomposed without losing information

6NF is primarily used in temporal databases and data warehousing scenarios.

### 6NF Example
```sql
-- Before 6NF: Time-variant employee data
CREATE TABLE employee_history_bad (
    employee_id INT,
    valid_from DATE,
    valid_to DATE,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    job_title VARCHAR(100),
    PRIMARY KEY (employee_id, valid_from)
);

-- Problem: When any attribute changes, entire row must be duplicated

-- After 6NF: Separate each time-variant attribute
CREATE TABLE employee_names (
    employee_id INT,
    valid_from DATE,
    valid_to DATE,
    name VARCHAR(100),
    PRIMARY KEY (employee_id, valid_from)
);

CREATE TABLE employee_departments (
    employee_id INT,
    valid_from DATE,
    valid_to DATE,
    department VARCHAR(50),
    PRIMARY KEY (employee_id, valid_from)
);

CREATE TABLE employee_salaries (
    employee_id INT,
    valid_from DATE,
    valid_to DATE,
    salary DECIMAL(10,2),
    PRIMARY KEY (employee_id, valid_from)
);

CREATE TABLE employee_titles (
    employee_id INT,
    valid_from DATE,
    valid_to DATE,
    job_title VARCHAR(100),
    PRIMARY KEY (employee_id, valid_from)
);
```

### Benefits of 6NF
- **Minimal Update Impact**: Changing one attribute doesn't affect others
- **Precise Temporal Tracking**: Each attribute has its own timeline
- **Storage Efficiency**: No redundant data for unchanged attributes

### When to Use 6NF
- **Temporal Databases**: When tracking historical changes is critical
- **Data Warehousing**: For slowly changing dimensions
- **Audit Systems**: When precise change tracking is required

## Denormalization Considerations {#denormalization}

### When to Denormalize
Normalization isn't always the best approach. Consider denormalization when:

1. **Performance Requirements**: Frequent joins are too expensive
2. **Read-Heavy Workloads**: Query performance is more important than storage
3. **Reporting Systems**: Aggregated data is frequently accessed
4. **OLAP Systems**: Analysis requires flattened data structures

### Controlled Denormalization Examples

#### Calculated Fields
```sql
-- Denormalized: Store calculated total
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    subtotal DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    total_amount DECIMAL(10,2), -- Denormalized: subtotal + tax_amount
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### Frequently Accessed Data
```sql
-- Denormalized: Include customer name in orders for reporting
CREATE TABLE orders_denorm (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100), -- Denormalized from customers table
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### Aggregated Data
```sql
-- Denormalized: Store summary statistics
CREATE TABLE customer_summary (
    customer_id INT PRIMARY KEY,
    total_orders INT,
    total_spent DECIMAL(10,2),
    last_order_date DATE,
    average_order_value DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

## Practical Examples {#practical-examples}

### E-commerce Database Normalization

#### Unnormalized Structure
```sql
CREATE TABLE sales_data_unnormalized (
    order_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_phone VARCHAR(15),
    product_name VARCHAR(200),
    product_category VARCHAR(50),
    product_price DECIMAL(10,2),
    quantity INT,
    order_date DATE,
    shipping_address TEXT,
    payment_method VARCHAR(50)
);
```

#### Fully Normalized Structure (3NF)
```sql
-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100) UNIQUE,
    customer_phone VARCHAR(15)
);

-- Product categories table
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INT,
    product_price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    shipping_address TEXT,
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items table
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2), -- Price at time of order
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Library Management System

```sql
-- Authors table
CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100),
    birth_date DATE,
    nationality VARCHAR(50)
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY,
    publisher_name VARCHAR(100),
    publisher_address TEXT,
    publisher_phone VARCHAR(15)
);

-- Books table
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    isbn VARCHAR(13) UNIQUE,
    title VARCHAR(200),
    publisher_id INT,
    publication_year INT,
    genre VARCHAR(50),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- Book authors (many-to-many relationship)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Members table
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    member_email VARCHAR(100),
    member_phone VARCHAR(15),
    membership_date DATE
);

-- Book copies table
CREATE TABLE book_copies (
    copy_id INT PRIMARY KEY,
    book_id INT,
    copy_condition VARCHAR(20),
    acquisition_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Loans table
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    member_id INT,
    copy_id INT,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id)
);
```

## Best Practices {#best-practices}

### 1. Progressive Normalization
- Start with unnormalized data
- Apply normalization rules incrementally
- Stop at the appropriate normal form for your use case

### 2. Consider Your Workload
```sql
-- For OLTP systems: Normalize to 3NF/BCNF
-- For OLAP systems: Consider star/snowflake schemas (controlled denormalization)
-- For reporting: May need materialized views or summary tables
```

### 3. Maintain Data Integrity
```sql
-- Use constraints to enforce relationships
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_customer 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Use check constraints for business rules
ALTER TABLE order_items 
ADD CONSTRAINT chk_quantity_positive 
CHECK (quantity > 0);

-- Use triggers for complex business logic
CREATE TRIGGER update_customer_summary 
AFTER INSERT ON orders 
FOR EACH ROW 
EXECUTE FUNCTION update_customer_totals();
```

### 4. Document Your Decisions
```sql
-- Document why certain denormalization decisions were made
COMMENT ON TABLE customer_summary IS 
'Denormalized table for performance - contains calculated aggregates from orders table';

COMMENT ON COLUMN orders.total_amount IS 
'Calculated field: subtotal + tax_amount - stored for reporting performance';
```

### 5. Monitor and Adjust
- Monitor query performance
- Use database profiling tools
- Adjust normalization level based on actual usage patterns
- Consider partitioning for large tables

### 6. Common Pitfalls to Avoid

#### Over-Normalization
```sql
-- DON'T: Over-normalize when it hurts performance
-- WRONG: Separate table for order status
CREATE TABLE order_statuses (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(20) -- 'pending', 'shipped', 'delivered'
);

-- BETTER: Use ENUM or simple VARCHAR with constraints
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status VARCHAR(20) CHECK (order_status IN ('pending', 'shipped', 'delivered')),
    -- ... other columns
);
```

#### Under-Normalization
```sql
-- DON'T: Leave obvious redundancy
-- WRONG: Duplicate customer info in every order
CREATE TABLE orders_bad (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    customer_phone VARCHAR(15),
    -- ... rest of order data
);
```

### Summary of Normal Forms

| Normal Form | Key Requirements | Benefits | Typical Use Cases |
|-------------|------------------|----------|-------------------|
| **1NF** | Atomic values, no repeating groups | Basic data integrity | All relational databases |
| **2NF** | 1NF + no partial dependencies | Eliminates redundancy in composite keys | OLTP systems |
| **3NF** | 2NF + no transitive dependencies | Standard for most applications | Business applications |
| **BCNF** | 3NF + every determinant is a candidate key | Handles complex dependencies | Academic, specialized systems |
| **4NF** | BCNF + no multi-valued dependencies | Eliminates independent multi-valued attributes | Complex relationship modeling |
| **5NF** | 4NF + no join dependencies | Eliminates all redundancy | Specialized analytical systems |
| **6NF** | 5NF + temporal considerations | Precise historical tracking | Temporal databases, auditing |

### When to Stop Normalizing

**Stop at 3NF when:**
- Building typical business applications
- Performance is a primary concern
- Team expertise is limited

**Go to BCNF when:**
- Data integrity is critical
- Complex business rules exist
- You have experienced database designers

**Consider 4NF+ when:**
- Building analytical systems
- Historical data tracking is required
- Storage efficiency is critical

The key is finding the right balance between data integrity, performance, and maintainability for your specific use case.