DROP DATABASE IF EXISTS danpss_db;
CREATE DATABASE danpss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE danpss_db;

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE designations (
    designation_id INT AUTO_INCREMENT PRIMARY KEY,
    designation_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employment_types (
    employment_type_id INT AUTO_INCREMENT PRIMARY KEY,
    employment_type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE post_types (
    post_type_id INT AUTO_INCREMENT PRIMARY KEY,
    post_type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE application_statuses (
    application_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE mentorship_domains (
    domain_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    graduation_year INT NULL,
    department_id INT NOT NULL,
    current_company_id INT NULL,
    designation_id INT NULL,
    experience_years INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_students_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_students_company FOREIGN KEY (current_company_id) REFERENCES companies(company_id),
    CONSTRAINT fk_students_designation FOREIGN KEY (designation_id) REFERENCES designations(designation_id)
);

CREATE TABLE alumni (
    alumni_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    graduation_year INT NOT NULL,
    department_id INT NOT NULL,
    company_id INT NOT NULL,
    designation_id INT NOT NULL,
    experience_years INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alumni_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_alumni_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_alumni_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT fk_alumni_designation FOREIGN KEY (designation_id) REFERENCES designations(designation_id)
);

CREATE TABLE student_skills (
    student_id INT NOT NULL,
    skill_id INT NOT NULL,
    PRIMARY KEY (student_id, skill_id),
    CONSTRAINT fk_student_skills_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_student_skills_skill FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE opportunities (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    post_type_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    company_id INT NOT NULL,
    location_id INT NOT NULL,
    employment_type_id INT NOT NULL,
    duration_months INT NULL,
    stipend_amount DECIMAL(10,2) NULL,
    stipend_currency CHAR(3) NULL,
    eligibility_notes TEXT NULL,
    posted_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_opportunities_post_type FOREIGN KEY (post_type_id) REFERENCES post_types(post_type_id),
    CONSTRAINT fk_opportunities_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT fk_opportunities_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_opportunities_employment_type FOREIGN KEY (employment_type_id) REFERENCES employment_types(employment_type_id)
);

CREATE TABLE opportunity_departments (
    opportunity_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (opportunity_id, department_id),
    CONSTRAINT fk_opp_departments_opportunity FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
    CONSTRAINT fk_opp_departments_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

CREATE TABLE opportunity_graduation_years (
    opportunity_id INT NOT NULL,
    graduation_year INT NOT NULL,
    PRIMARY KEY (opportunity_id, graduation_year),
    CONSTRAINT fk_opp_years_opportunity FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id) ON DELETE CASCADE
);

CREATE TABLE opportunity_skills (
    opportunity_id INT NOT NULL,
    skill_id INT NOT NULL,
    PRIMARY KEY (opportunity_id, skill_id),
    CONSTRAINT fk_opp_skills_opportunity FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
    CONSTRAINT fk_opp_skills_skill FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    opportunity_id INT NOT NULL,
    application_status_id INT NOT NULL,
    application_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_applications_student_opportunity UNIQUE (student_id, opportunity_id),
    CONSTRAINT fk_applications_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_applications_opportunity FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id),
    CONSTRAINT fk_applications_status FOREIGN KEY (application_status_id) REFERENCES application_statuses(application_status_id)
);

CREATE TABLE mentorships (
    mentorship_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT NOT NULL,
    domain_id INT NOT NULL,
    eligibility_notes TEXT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mentorships_alumni FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id),
    CONSTRAINT fk_mentorships_domain FOREIGN KEY (domain_id) REFERENCES mentorship_domains(domain_id)
);

CREATE TABLE matching_rules (
    rule_key VARCHAR(50) PRIMARY KEY,
    rule_value VARCHAR(100) NOT NULL
);

INSERT INTO roles (role_name) VALUES
('Student'),
('Alumni'),
('Placement Officer');

INSERT INTO departments (department_name) VALUES
('Computer Science'),
('Information Technology');

INSERT INTO companies (company_name) VALUES
('CloudNest'),
('DataBridge'),
('PixelForge'),
('TechNova');

INSERT INTO designations (designation_name) VALUES
('Final Year Student'),
('Software Engineer'),
('Student Intern'),
('Senior Engineer'),
('Analytics Lead'),
('Placement Officer');

INSERT INTO locations (location_name) VALUES
('Bengaluru'),
('Remote'),
('Hyderabad');

INSERT INTO employment_types (employment_type_name) VALUES
('Full Time'),
('Part Time'),
('Internship'),
('Remote');

INSERT INTO post_types (post_type_name) VALUES
('Job'),
('Internship');

INSERT INTO application_statuses (status_name) VALUES
('Applied'),
('Interview Scheduled'),
('Selected'),
('Rejected');

INSERT INTO mentorship_domains (domain_name) VALUES
('Software Engineering'),
('Data Analytics');

INSERT INTO skills (skill_name) VALUES
('java'),
('mysql'),
('jsp'),
('html'),
('css'),
('spring'),
('sql'),
('restful api'),
('python'),
('data analysis'),
('power bi'),
('excel'),
('javascript'),
('ui');

INSERT INTO users (full_name, email, phone, password_hash, role_id) VALUES
('Aarav Student', 'student@danpss.local', '9876543210', SHA2('password123', 256), 1),
('Mira Alumni', 'alumni@danpss.local', '9876543211', SHA2('password123', 256), 2),
('Rohan Officer', 'officer@danpss.local', '9876543212', SHA2('password123', 256), 3),
('Neha Joseph', 'neha.joseph@danpss.local', '9876543220', SHA2('password123', 256), 1),
('Aditya Rao', 'aditya.rao@danpss.local', '9876543221', SHA2('password123', 256), 1),
('Karan Mehta', 'karan.mehta@danpss.local', '9876543222', SHA2('password123', 256), 2);

INSERT INTO students (user_id, graduation_year, department_id, current_company_id, designation_id, experience_years) VALUES
(1, 2026, 1, NULL, 1, 0),
(4, 2025, 2, 4, 2, 1),
(5, 2027, 1, NULL, 3, 0);

INSERT INTO alumni (user_id, graduation_year, department_id, company_id, designation_id, experience_years) VALUES
(2, 2019, 1, 1, 4, 6),
(6, 2018, 2, 2, 5, 7);

INSERT INTO student_skills (student_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 6), (2, 1), (2, 7), (2, 8),
(3, 9), (3, 10), (3, 11);

INSERT INTO opportunities (post_type_id, title, company_id, location_id, employment_type_id, duration_months, stipend_amount, stipend_currency, eligibility_notes, posted_date) VALUES
(1, 'Java Developer', 1, 1, 1, NULL, NULL, NULL, 'Open to Computer Science and Information Technology students.', CURDATE()),
(2, 'Data Analyst Intern', 2, 2, 3, 6, 25000.00, 'INR', 'Preferred skills include Python, Excel, and Power BI.', CURDATE()),
(1, 'Frontend Developer', 3, 3, 4, NULL, NULL, NULL, 'Open to students with HTML, CSS, JavaScript, and UI portfolio experience.', CURDATE());

INSERT INTO opportunity_departments (opportunity_id, department_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2),
(3, 1), (3, 2);

INSERT INTO opportunity_graduation_years (opportunity_id, graduation_year) VALUES
(1, 2025), (1, 2026),
(2, 2026), (2, 2027);

INSERT INTO opportunity_skills (opportunity_id, skill_id) VALUES
(1, 1), (1, 7),
(2, 9), (2, 12), (2, 11),
(3, 4), (3, 5), (3, 13), (3, 14);

INSERT INTO applications (student_id, opportunity_id, application_status_id, application_date) VALUES
(1, 1, 1, CURDATE()),
(2, 1, 2, CURDATE()),
(3, 2, 1, CURDATE());

INSERT INTO mentorships (alumni_id, domain_id, eligibility_notes, start_date, end_date) VALUES
(1, 1, 'Open to students interested in Java backend development.', CURDATE(), NULL),
(2, 2, 'Open to students with SQL and dashboarding basics.', CURDATE(), NULL);

INSERT INTO matching_rules (rule_key, rule_value) VALUES
('skills_weight', '0.50'),
('eligibility_weight', '0.30'),
('graduation_year_weight', '0.20'),
('minimum_match_score', '0.45'),
('max_recommendations', '10');
