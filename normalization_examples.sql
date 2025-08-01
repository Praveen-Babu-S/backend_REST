-- SQL Database Normalization Examples
-- This script demonstrates each normal form with practical examples

-- =============================================
-- UNNORMALIZED TABLE (0NF) - BEFORE NORMALIZATION
-- =============================================

-- This table violates multiple normalization rules
CREATE TABLE student_data_unnormalized (
    student_id INT,
    student_name VARCHAR(100),
    student_phone VARCHAR(15),
    student_email VARCHAR(100),
    course1 VARCHAR(50),
    course1_instructor VARCHAR(100),
    course1_grade CHAR(2),
    course2 VARCHAR(50),
    course2_instructor VARCHAR(100),
    course2_grade CHAR(2),
    course3 VARCHAR(50),
    course3_instructor VARCHAR(100),
    course3_grade CHAR(2),
    skills VARCHAR(200), -- "Java, Python, SQL"
    hobbies VARCHAR(200), -- "Reading, Gaming, Sports"
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    advisor_phone VARCHAR(15)
);

-- Sample data showing the problems
INSERT INTO student_data_unnormalized VALUES 
(1, 'John Doe', '123-456-7890', 'john@email.com', 
 'Mathematics', 'Dr. Smith', 'A', 'Physics', 'Dr. Johnson', 'B', 'Chemistry', 'Dr. Brown', 'A',
 'Java, Python, SQL', 'Reading, Gaming', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com',
 'Physics', 'Dr. Johnson', 'A', 'Chemistry', 'Dr. Brown', 'B', NULL, NULL, NULL,
 'C++, JavaScript', 'Sports, Music', 'Prof. Wilson', 'Room 101', '555-0001');

-- Problems with this structure:
-- 1. Repeating groups (course1, course2, course3)
-- 2. Multi-valued attributes (skills, hobbies)
-- 3. Partial dependencies
-- 4. Transitive dependencies
-- 5. Data redundancy (advisor info repeated)

SELECT * FROM student_data_unnormalized;

-- =============================================
-- FIRST NORMAL FORM (1NF)
-- =============================================

-- Rule: Eliminate repeating groups and multi-valued attributes
-- Each cell should contain atomic (indivisible) values

-- 1NF: Remove repeating groups and multi-valued attributes
CREATE TABLE students_1nf (
    student_id INT,
    student_name VARCHAR(100),
    student_phone VARCHAR(15),
    student_email VARCHAR(100),
    course VARCHAR(50),
    instructor VARCHAR(100),
    grade CHAR(2),
    skill VARCHAR(50),
    hobby VARCHAR(50),
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    advisor_phone VARCHAR(15)
);

-- Insert normalized data (atomic values only)
INSERT INTO students_1nf VALUES 
-- Student 1 data
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'Java', 'Reading', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'Java', 'Gaming', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'Python', 'Reading', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'Python', 'Gaming', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'SQL', 'Reading', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Mathematics', 'Dr. Smith', 'A', 'SQL', 'Gaming', 'Prof. Wilson', 'Room 101', '555-0001'),
-- Add Physics course for student 1
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Physics', 'Dr. Johnson', 'B', 'Java', 'Reading', 'Prof. Wilson', 'Room 101', '555-0001'),
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Physics', 'Dr. Johnson', 'B', 'Java', 'Gaming', 'Prof. Wilson', 'Room 101', '555-0001'),
-- ... (This gets unwieldy fast!)

-- Student 2 data
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Physics', 'Dr. Johnson', 'A', 'C++', 'Sports', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Physics', 'Dr. Johnson', 'A', 'C++', 'Music', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Physics', 'Dr. Johnson', 'A', 'JavaScript', 'Sports', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Physics', 'Dr. Johnson', 'A', 'JavaScript', 'Music', 'Prof. Wilson', 'Room 101', '555-0001');

-- Better 1NF: Separate tables for different entity types
CREATE TABLE students_1nf_better (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_phone VARCHAR(15),
    student_email VARCHAR(100),
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    advisor_phone VARCHAR(15)
);

CREATE TABLE enrollments_1nf (
    student_id INT,
    course VARCHAR(50),
    instructor VARCHAR(100),
    grade CHAR(2),
    PRIMARY KEY (student_id, course)
);

CREATE TABLE student_skills_1nf (
    student_id INT,
    skill VARCHAR(50),
    PRIMARY KEY (student_id, skill)
);

CREATE TABLE student_hobbies_1nf (
    student_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, hobby)
);

-- Insert better 1NF data
INSERT INTO students_1nf_better VALUES 
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Prof. Wilson', 'Room 101', '555-0001');

INSERT INTO enrollments_1nf VALUES 
(1, 'Mathematics', 'Dr. Smith', 'A'),
(1, 'Physics', 'Dr. Johnson', 'B'),
(1, 'Chemistry', 'Dr. Brown', 'A'),
(2, 'Physics', 'Dr. Johnson', 'A'),
(2, 'Chemistry', 'Dr. Brown', 'B');

INSERT INTO student_skills_1nf VALUES 
(1, 'Java'), (1, 'Python'), (1, 'SQL'),
(2, 'C++'), (2, 'JavaScript');

INSERT INTO student_hobbies_1nf VALUES 
(1, 'Reading'), (1, 'Gaming'),
(2, 'Sports'), (2, 'Music');

-- =============================================
-- SECOND NORMAL FORM (2NF)
-- =============================================

-- Rule: 1NF + No partial dependencies
-- Every non-key attribute must be fully functionally dependent on the primary key

-- Current enrollments_1nf table has partial dependencies:
-- student_id -> student_name (partial dependency on composite key)
-- course -> instructor (partial dependency)

-- 2NF: Eliminate partial dependencies
CREATE TABLE students_2nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_phone VARCHAR(15),
    student_email VARCHAR(100),
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    advisor_phone VARCHAR(15)
);

CREATE TABLE courses_2nf (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    instructor VARCHAR(100),
    credits INT
);

CREATE TABLE enrollments_2nf (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students_2nf(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_2nf(course_id)
);

-- Insert 2NF data
INSERT INTO students_2nf VALUES 
(1, 'John Doe', '123-456-7890', 'john@email.com', 'Prof. Wilson', 'Room 101', '555-0001'),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 'Prof. Wilson', 'Room 101', '555-0001'),
(3, 'Bob Johnson', '555-123-4567', 'bob@email.com', 'Prof. Davis', 'Room 102', '555-0002');

INSERT INTO courses_2nf VALUES 
(101, 'Mathematics', 'Dr. Smith', 3),
(102, 'Physics', 'Dr. Johnson', 4),
(103, 'Chemistry', 'Dr. Brown', 3),
(104, 'Computer Science', 'Dr. Wilson', 4);

INSERT INTO enrollments_2nf VALUES 
(1, 101, 'A', '2024-01-15'),
(1, 102, 'B', '2024-01-15'),
(1, 103, 'A', '2024-01-15'),
(2, 102, 'A', '2024-01-15'),
(2, 103, 'B', '2024-01-15'),
(3, 101, 'B', '2024-01-15'),
(3, 104, 'A', '2024-01-15');

-- Skills and hobbies remain the same (already in 2NF)
CREATE TABLE student_skills_2nf (
    student_id INT,
    skill VARCHAR(50),
    proficiency_level VARCHAR(20),
    PRIMARY KEY (student_id, skill),
    FOREIGN KEY (student_id) REFERENCES students_2nf(student_id)
);

CREATE TABLE student_hobbies_2nf (
    student_id INT,
    hobby VARCHAR(50),
    frequency VARCHAR(20), -- 'Daily', 'Weekly', 'Monthly'
    PRIMARY KEY (student_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students_2nf(student_id)
);

INSERT INTO student_skills_2nf VALUES 
(1, 'Java', 'Advanced'), (1, 'Python', 'Intermediate'), (1, 'SQL', 'Beginner'),
(2, 'C++', 'Advanced'), (2, 'JavaScript', 'Intermediate'),
(3, 'Python', 'Advanced'), (3, 'Machine Learning', 'Beginner');

INSERT INTO student_hobbies_2nf VALUES 
(1, 'Reading', 'Daily'), (1, 'Gaming', 'Weekly'),
(2, 'Sports', 'Daily'), (2, 'Music', 'Weekly'),
(3, 'Photography', 'Weekly'), (3, 'Hiking', 'Monthly');

-- =============================================
-- THIRD NORMAL FORM (3NF)
-- =============================================

-- Rule: 2NF + No transitive dependencies
-- No non-key attribute should depend on another non-key attribute

-- Current students_2nf table has transitive dependencies:
-- advisor_name -> advisor_office, advisor_phone

-- 3NF: Eliminate transitive dependencies
CREATE TABLE advisors_3nf (
    advisor_id INT PRIMARY KEY,
    advisor_name VARCHAR(100),
    advisor_office VARCHAR(20),
    advisor_phone VARCHAR(15),
    department VARCHAR(50)
);

CREATE TABLE students_3nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_phone VARCHAR(15),
    student_email VARCHAR(100),
    advisor_id INT,
    major VARCHAR(50),
    enrollment_year INT,
    FOREIGN KEY (advisor_id) REFERENCES advisors_3nf(advisor_id)
);

CREATE TABLE instructors_3nf (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100),
    department VARCHAR(50),
    office VARCHAR(20),
    phone VARCHAR(15)
);

CREATE TABLE courses_3nf (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    course_code VARCHAR(10),
    instructor_id INT,
    credits INT,
    department VARCHAR(50),
    FOREIGN KEY (instructor_id) REFERENCES instructors_3nf(instructor_id)
);

CREATE TABLE enrollments_3nf (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    enrollment_date DATE,
    semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES students_3nf(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_3nf(course_id)
);

-- Insert 3NF data
INSERT INTO advisors_3nf VALUES 
(1, 'Prof. Wilson', 'Room 101', '555-0001', 'Computer Science'),
(2, 'Prof. Davis', 'Room 102', '555-0002', 'Mathematics'),
(3, 'Prof. Martinez', 'Room 103', '555-0003', 'Physics');

INSERT INTO instructors_3nf VALUES 
(1, 'Dr. Smith', 'Mathematics', 'Room 201', '555-1001'),
(2, 'Dr. Johnson', 'Physics', 'Room 202', '555-1002'),
(3, 'Dr. Brown', 'Chemistry', 'Room 203', '555-1003'),
(4, 'Dr. Wilson', 'Computer Science', 'Room 204', '555-1004');

INSERT INTO students_3nf VALUES 
(1, 'John Doe', '123-456-7890', 'john@email.com', 1, 'Computer Science', 2022),
(2, 'Jane Smith', '098-765-4321', 'jane@email.com', 1, 'Computer Science', 2023),
(3, 'Bob Johnson', '555-123-4567', 'bob@email.com', 2, 'Mathematics', 2022),
(4, 'Alice Brown', '777-888-9999', 'alice@email.com', 3, 'Physics', 2023);

INSERT INTO courses_3nf VALUES 
(101, 'Calculus I', 'MATH101', 1, 3, 'Mathematics'),
(102, 'Physics I', 'PHYS101', 2, 4, 'Physics'),
(103, 'General Chemistry', 'CHEM101', 3, 3, 'Chemistry'),
(104, 'Data Structures', 'CS201', 4, 4, 'Computer Science'),
(105, 'Database Systems', 'CS301', 4, 3, 'Computer Science');

INSERT INTO enrollments_3nf VALUES 
(1, 101, 'A', '2024-01-15', 'Spring 2024'),
(1, 104, 'A', '2024-01-15', 'Spring 2024'),
(1, 105, 'B', '2024-01-15', 'Spring 2024'),
(2, 102, 'A', '2024-01-15', 'Spring 2024'),
(2, 104, 'B', '2024-01-15', 'Spring 2024'),
(3, 101, 'B', '2024-01-15', 'Spring 2024'),
(3, 102, 'A', '2024-01-15', 'Spring 2024'),
(4, 102, 'A', '2024-01-15', 'Spring 2024'),
(4, 103, 'B', '2024-01-15', 'Spring 2024');

-- =============================================
-- BOYCE-CODD NORMAL FORM (BCNF)
-- =============================================

-- Rule: 3NF + Every determinant is a candidate key
-- Example: Court scheduling system

-- Violates BCNF: Each instructor teaches only one subject
CREATE TABLE court_schedule_bad (
    court_id VARCHAR(10),
    time_slot VARCHAR(20),
    sport VARCHAR(30),
    instructor VARCHAR(100),
    PRIMARY KEY (court_id, time_slot)
);

-- Problem: instructor -> sport, but instructor is not a candidate key

-- BCNF Solution:
CREATE TABLE instructors_bcnf (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100),
    sport VARCHAR(30),
    certification_level VARCHAR(20)
);

CREATE TABLE court_schedule_bcnf (
    court_id VARCHAR(10),
    time_slot VARCHAR(20),
    instructor_id INT,
    session_type VARCHAR(30), -- 'Training', 'Match', 'Practice'
    max_participants INT,
    PRIMARY KEY (court_id, time_slot),
    FOREIGN KEY (instructor_id) REFERENCES instructors_bcnf(instructor_id)
);

-- Insert BCNF data
INSERT INTO instructors_bcnf VALUES 
(1, 'Mike Tennis', 'Tennis', 'Professional'),
(2, 'Sarah Basketball', 'Basketball', 'Advanced'),
(3, 'Tom Swimming', 'Swimming', 'Professional'),
(4, 'Lisa Yoga', 'Yoga', 'Certified');

INSERT INTO court_schedule_bcnf VALUES 
('COURT-A', '09:00-10:00', 1, 'Training', 4),
('COURT-A', '10:00-11:00', 1, 'Match', 2),
('COURT-B', '09:00-10:00', 2, 'Training', 10),
('COURT-C', '14:00-15:00', 3, 'Training', 6),
('STUDIO-1', '18:00-19:00', 4, 'Class', 15);

-- =============================================
-- FOURTH NORMAL FORM (4NF)
-- =============================================

-- Rule: BCNF + No multi-valued dependencies
-- Example: Students with courses and extracurricular activities

-- Violates 4NF: Creates unnecessary combinations
CREATE TABLE student_activities_bad (
    student_id INT,
    course VARCHAR(50),
    activity VARCHAR(50),
    PRIMARY KEY (student_id, course, activity)
);

-- Problem: Courses and activities are independent multi-valued dependencies

-- 4NF Solution:
CREATE TABLE student_courses_4nf (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES students_3nf(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_3nf(course_id)
);

CREATE TABLE extracurricular_activities (
    activity_id INT PRIMARY KEY,
    activity_name VARCHAR(100),
    activity_type VARCHAR(50), -- 'Sports', 'Academic', 'Arts', 'Service'
    advisor VARCHAR(100)
);

CREATE TABLE student_activities_4nf (
    student_id INT,
    activity_id INT,
    role VARCHAR(50), -- 'Member', 'Officer', 'President'
    join_date DATE,
    PRIMARY KEY (student_id, activity_id),
    FOREIGN KEY (student_id) REFERENCES students_3nf(student_id),
    FOREIGN KEY (activity_id) REFERENCES extracurricular_activities(activity_id)
);

-- Insert 4NF data
INSERT INTO extracurricular_activities VALUES 
(1, 'Chess Club', 'Academic', 'Prof. King'),
(2, 'Soccer Team', 'Sports', 'Coach Smith'),
(3, 'Drama Society', 'Arts', 'Ms. Theater'),
(4, 'Volunteer Corps', 'Service', 'Dr. Helper'),
(5, 'Debate Team', 'Academic', 'Prof. Argue');

INSERT INTO student_activities_4nf VALUES 
(1, 1, 'President', '2023-09-01'),
(1, 4, 'Member', '2023-10-15'),
(2, 2, 'Member', '2023-09-01'),
(2, 3, 'Officer', '2023-09-15'),
(3, 1, 'Member', '2023-09-01'),
(3, 5, 'Member', '2023-10-01'),
(4, 2, 'Officer', '2023-09-01'),
(4, 4, 'President', '2023-09-01');

-- =============================================
-- FIFTH NORMAL FORM (5NF)
-- =============================================

-- Rule: 4NF + No join dependencies
-- Example: Supplier-Part-Project relationships

-- Violates 5NF: Join dependency exists
CREATE TABLE supplier_part_project_bad (
    supplier VARCHAR(50),
    part VARCHAR(50),
    project VARCHAR(50),
    PRIMARY KEY (supplier, part, project)
);

-- Business rules:
-- 1. Suppliers supply parts
-- 2. Parts are used in projects
-- 3. Suppliers work on projects
-- 4. A supplier supplies a part to a project only if all three relationships exist

-- 5NF Solution:
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_info VARCHAR(200)
);

CREATE TABLE parts (
    part_id INT PRIMARY KEY,
    part_name VARCHAR(100),
    part_category VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE
);

CREATE TABLE supplier_parts_5nf (
    supplier_id INT,
    part_id INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (supplier_id, part_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

CREATE TABLE part_projects_5nf (
    part_id INT,
    project_id INT,
    quantity_needed INT,
    PRIMARY KEY (part_id, project_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE supplier_projects_5nf (
    supplier_id INT,
    project_id INT,
    contract_start DATE,
    contract_end DATE,
    PRIMARY KEY (supplier_id, project_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Insert 5NF data
INSERT INTO suppliers VALUES 
(1, 'TechCorp Inc', 'contact@techcorp.com'),
(2, 'MetalWorks Ltd', 'info@metalworks.com'),
(3, 'PlasticPro Co', 'sales@plasticpro.com');

INSERT INTO parts VALUES 
(1, 'Steel Beam', 'Structural'),
(2, 'Circuit Board', 'Electronics'),
(3, 'Plastic Housing', 'Enclosure'),
(4, 'Power Cable', 'Electronics');

INSERT INTO projects VALUES 
(1, 'Office Building', '2024-01-01', '2024-12-31'),
(2, 'Smart Device', '2024-02-01', '2024-08-31'),
(3, 'Industrial Robot', '2024-03-01', '2024-10-31');

INSERT INTO supplier_parts_5nf VALUES 
(1, 2, 25.50), (1, 4, 15.75),
(2, 1, 125.00), (2, 4, 12.50),
(3, 3, 8.25);

INSERT INTO part_projects_5nf VALUES 
(1, 1, 100), -- Steel beams for office building
(2, 2, 50),  -- Circuit boards for smart device
(2, 3, 25),  -- Circuit boards for robot
(3, 2, 200), -- Plastic housing for smart device
(4, 2, 150), -- Power cables for smart device
(4, 3, 75);  -- Power cables for robot

INSERT INTO supplier_projects_5nf VALUES 
(1, 2, '2024-02-01', '2024-08-31'), -- TechCorp on Smart Device
(1, 3, '2024-03-01', '2024-10-31'), -- TechCorp on Robot
(2, 1, '2024-01-01', '2024-12-31'), -- MetalWorks on Building
(2, 2, '2024-02-01', '2024-08-31'), -- MetalWorks on Smart Device
(3, 2, '2024-02-01', '2024-08-31'); -- PlasticPro on Smart Device

-- =============================================
-- DEMONSTRATION QUERIES
-- =============================================

-- Show data evolution through normal forms
\echo 'Unnormalized data problems:'
SELECT COUNT(*) as "Rows in unnormalized table" FROM student_data_unnormalized;

\echo 'After 1NF - atomic values:'
SELECT COUNT(*) as "Students" FROM students_1nf_better;
SELECT COUNT(*) as "Enrollments" FROM enrollments_1nf;
SELECT COUNT(*) as "Skills" FROM student_skills_1nf;

\echo 'After 2NF - no partial dependencies:'
SELECT COUNT(*) as "Students" FROM students_2nf;
SELECT COUNT(*) as "Courses" FROM courses_2nf;
SELECT COUNT(*) as "Enrollments" FROM enrollments_2nf;

\echo 'After 3NF - no transitive dependencies:'
SELECT COUNT(*) as "Students" FROM students_3nf;
SELECT COUNT(*) as "Advisors" FROM advisors_3nf;
SELECT COUNT(*) as "Instructors" FROM instructors_3nf;
SELECT COUNT(*) as "Courses" FROM courses_3nf;

\echo 'Complex query joining 3NF tables:'
SELECT 
    s.student_name,
    s.major,
    a.advisor_name,
    c.course_name,
    e.grade,
    i.instructor_name
FROM students_3nf s
JOIN advisors_3nf a ON s.advisor_id = a.advisor_id
JOIN enrollments_3nf e ON s.student_id = e.student_id
JOIN courses_3nf c ON e.course_id = c.course_id
JOIN instructors_3nf i ON c.instructor_id = i.instructor_id
WHERE s.major = 'Computer Science'
ORDER BY s.student_name, c.course_name;

\echo '5NF example - parts that can be supplied to projects:'
-- This query recreates the original 3-way relationship from the decomposed tables
SELECT 
    sup.supplier_name,
    p.part_name,
    proj.project_name
FROM suppliers sup
JOIN supplier_parts_5nf sp ON sup.supplier_id = sp.supplier_id
JOIN part_projects_5nf pp ON sp.part_id = pp.part_id
JOIN supplier_projects_5nf spr ON sup.supplier_id = spr.supplier_id AND pp.project_id = spr.project_id
JOIN parts p ON sp.part_id = p.part_id
JOIN projects proj ON pp.project_id = proj.project_id
ORDER BY sup.supplier_name, proj.project_name, p.part_name;

-- =============================================
-- CLEANUP (Uncomment to remove all tables)
-- =============================================

/*
DROP TABLE IF EXISTS student_data_unnormalized CASCADE;
DROP TABLE IF EXISTS students_1nf CASCADE;
DROP TABLE IF EXISTS students_1nf_better CASCADE;
DROP TABLE IF EXISTS enrollments_1nf CASCADE;
DROP TABLE IF EXISTS student_skills_1nf CASCADE;
DROP TABLE IF EXISTS student_hobbies_1nf CASCADE;
DROP TABLE IF EXISTS students_2nf CASCADE;
DROP TABLE IF EXISTS courses_2nf CASCADE;
DROP TABLE IF EXISTS enrollments_2nf CASCADE;
DROP TABLE IF EXISTS student_skills_2nf CASCADE;
DROP TABLE IF EXISTS student_hobbies_2nf CASCADE;
DROP TABLE IF EXISTS advisors_3nf CASCADE;
DROP TABLE IF EXISTS students_3nf CASCADE;
DROP TABLE IF EXISTS instructors_3nf CASCADE;
DROP TABLE IF EXISTS courses_3nf CASCADE;
DROP TABLE IF EXISTS enrollments_3nf CASCADE;
DROP TABLE IF EXISTS court_schedule_bad CASCADE;
DROP TABLE IF EXISTS instructors_bcnf CASCADE;
DROP TABLE IF EXISTS court_schedule_bcnf CASCADE;
DROP TABLE IF EXISTS student_activities_bad CASCADE;
DROP TABLE IF EXISTS student_courses_4nf CASCADE;
DROP TABLE IF EXISTS extracurricular_activities CASCADE;
DROP TABLE IF EXISTS student_activities_4nf CASCADE;
DROP TABLE IF EXISTS supplier_part_project_bad CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS parts CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS supplier_parts_5nf CASCADE;
DROP TABLE IF EXISTS part_projects_5nf CASCADE;
DROP TABLE IF EXISTS supplier_projects_5nf CASCADE;
*/