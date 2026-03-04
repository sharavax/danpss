CREATE DATABASE IF NOT EXISTS danpss_db;
USE danpss_db;

CREATE TABLE IF NOT EXISTS alumni(
 alumni_id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 email VARCHAR(100),
 phone VARCHAR(10),
 graduation_year INT,
 department VARCHAR(50),
 company VARCHAR(100),
 designation VARCHAR(100),
 experience INT,
 password VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS student(
 student_id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 email VARCHAR(100),
 phone VARCHAR(10),
 graduation_year INT,
 department VARCHAR(50),
 company VARCHAR(100),
 designation VARCHAR(100),
 experience INT,
 skills VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS job(
 job_id INT AUTO_INCREMENT PRIMARY KEY,
 title VARCHAR(100),
 company VARCHAR(100),
 location VARCHAR(100),
 job_type VARCHAR(50),
 eligibility TEXT,
 posted_date DATE
);

CREATE TABLE IF NOT EXISTS internship(
 internship_id INT AUTO_INCREMENT PRIMARY KEY,
 role VARCHAR(100),
 company VARCHAR(100),
 duration INT,
 stipend VARCHAR(50),
 eligibility TEXT
);

CREATE TABLE IF NOT EXISTS application(
 application_id INT AUTO_INCREMENT PRIMARY KEY,
 application_date DATE,
 status VARCHAR(50),
 student_id INT,
 job_id INT,
 internship_id INT
);

CREATE TABLE IF NOT EXISTS mentorship(
 mentorship_id INT AUTO_INCREMENT PRIMARY KEY,
 start_date DATE,
 end_date DATE,
 domain VARCHAR(100),
 eligibility TEXT,
 alumni_id INT
);

-- Added compatibility tables to match servlets (users, students, jobs)
CREATE TABLE IF NOT EXISTS users (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 role VARCHAR(50),
 email VARCHAR(100) UNIQUE,
 phone VARCHAR(20),
 password VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS students (
 student_id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 email VARCHAR(100),
 phone VARCHAR(20),
 graduation_year INT,
 department VARCHAR(50),
 company VARCHAR(100),
 designation VARCHAR(100),
 experience INT,
 skills VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS jobs (
 job_id INT AUTO_INCREMENT PRIMARY KEY,
 post_type VARCHAR(50),
 title VARCHAR(100),
 company VARCHAR(100),
 location VARCHAR(100),
 job_type VARCHAR(50),
 eligibility TEXT,
 duration INT,
 stipend VARCHAR(50),
 posted_date DATE
);

-- Rule configuration used by dashboard recommendations
CREATE TABLE IF NOT EXISTS matching_rules (
 rule_key VARCHAR(50) PRIMARY KEY,
 rule_value VARCHAR(100) NOT NULL
);

INSERT INTO matching_rules (rule_key, rule_value) VALUES
('skills_weight', '0.50'),
('eligibility_weight', '0.30'),
('graduation_year_weight', '0.20'),
('minimum_match_score', '0.45'),
('max_recommendations', '10')
ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value);

-- ==============================
-- Migration: merge old singular tables into new plural tables
-- This section preserves existing IDs where possible, updates
-- application references, and drops legacy tables.
-- Run this once on the target MySQL instance. It is safe to re-run
-- because INSERTs use primary key membership and UPDATEs are idempotent.
-- ==============================

-- Temporarily disable foreign key checks for migration
SET @OLD_FK = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- 1) Migrate rows from `student` -> `students` preserving `student_id`
INSERT INTO students (student_id, name, email, phone, graduation_year, department, company, designation, experience, skills)
SELECT student_id, name, email, phone, graduation_year, department, company, designation, experience, skills
FROM student
ON DUPLICATE KEY UPDATE
 name = VALUES(name),
 email = VALUES(email),
 phone = VALUES(phone),
 graduation_year = VALUES(graduation_year),
 department = VALUES(department),
 company = VALUES(company),
 designation = VALUES(designation),
 experience = VALUES(experience),
 skills = VALUES(skills);

-- 2) Migrate `job` rows into `jobs` (mark as post_type = 'Job')
INSERT INTO jobs (job_id, post_type, title, company, location, job_type, eligibility, duration, stipend, posted_date)
SELECT job_id, 'Job', title, company, location, job_type, eligibility, NULL, NULL, posted_date
FROM job
ON DUPLICATE KEY UPDATE
 title = VALUES(title),
 company = VALUES(company),
 location = VALUES(location),
 job_type = VALUES(job_type),
 eligibility = VALUES(eligibility),
 posted_date = VALUES(posted_date);

-- 3) Migrate `internship` rows into `jobs` (preserve internship_id as job_id)
INSERT INTO jobs (job_id, post_type, title, company, location, job_type, eligibility, duration, stipend, posted_date)
SELECT internship_id, 'Internship', role, company, NULL, 'Internship', eligibility, duration, stipend, NULL
FROM internship
ON DUPLICATE KEY UPDATE
 title = VALUES(title),
 company = VALUES(company),
 eligibility = VALUES(eligibility),
 duration = VALUES(duration),
 stipend = VALUES(stipend);

-- 4) Consolidate application references: move internship references into job_id where applicable
UPDATE application SET job_id = COALESCE(job_id, internship_id);

-- 5) Drop obsolete column and legacy tables
ALTER TABLE application DROP COLUMN internship_id;

DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS job;
DROP TABLE IF EXISTS internship;

-- Restore FK checks
SET FOREIGN_KEY_CHECKS = @OLD_FK;

-- ==============================
-- Indexes and Foreign Keys
-- Add indexes for faster lookups and FK constraints to ensure referential integrity.
-- Review before running on production; ensure no conflicting constraint names exist.
-- ==============================

-- Indexes
CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);
CREATE INDEX IF NOT EXISTS idx_jobs_company ON jobs(company);
CREATE INDEX IF NOT EXISTS idx_jobs_post_type ON jobs(post_type);
CREATE INDEX IF NOT EXISTS idx_application_date ON application(application_date);

-- Foreign keys (add with descriptive names)
ALTER TABLE application
	ADD CONSTRAINT fk_application_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE SET NULL ON UPDATE CASCADE,
	ADD CONSTRAINT fk_application_job FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE mentorship
	ADD CONSTRAINT fk_mentorship_alumni FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id) ON DELETE SET NULL ON UPDATE CASCADE;
