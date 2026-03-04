-- Placement analytics queries for DANPSS
-- Use the same optional filters as report screens:
--   :department (VARCHAR)
--   :graduation_year (INT)
--   :company (VARCHAR)
--   :post_type (VARCHAR)

USE danpss_db;

-- 1) Overall placement summary
-- "Placed" is inferred when a student has both company and designation populated.
SELECT
    COUNT(*) AS total_students,
    SUM(CASE WHEN company IS NOT NULL AND company <> '' AND designation IS NOT NULL AND designation <> '' THEN 1 ELSE 0 END) AS placed_students,
    ROUND(
        100.0 * SUM(CASE WHEN company IS NOT NULL AND company <> '' AND designation IS NOT NULL AND designation <> '' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS placement_rate_percent
FROM students
WHERE (? IS NULL OR ? = '' OR department = ?)
  AND (? IS NULL OR ? = '' OR graduation_year = ?)
  AND (? IS NULL OR ? = '' OR company = ?);

-- 2) Department-wise placement breakdown
SELECT
    department,
    COUNT(*) AS total_students,
    SUM(CASE WHEN company IS NOT NULL AND company <> '' AND designation IS NOT NULL AND designation <> '' THEN 1 ELSE 0 END) AS placed_students,
    ROUND(
        100.0 * SUM(CASE WHEN company IS NOT NULL AND company <> '' AND designation IS NOT NULL AND designation <> '' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS placement_rate_percent
FROM students
WHERE (? IS NULL OR ? = '' OR graduation_year = ?)
  AND (? IS NULL OR ? = '' OR company = ?)
GROUP BY department
ORDER BY placement_rate_percent DESC, department ASC;

-- 3) Company-wise hired students
SELECT
    company,
    COUNT(*) AS hired_students
FROM students
WHERE company IS NOT NULL
  AND company <> ''
  AND (? IS NULL OR ? = '' OR department = ?)
  AND (? IS NULL OR ? = '' OR graduation_year = ?)
GROUP BY company
ORDER BY hired_students DESC, company ASC
LIMIT 10;

-- 4) Search/filter student placement details
SELECT
    student_id,
    name,
    email,
    department,
    graduation_year,
    company,
    designation
FROM students
WHERE (? IS NULL OR ? = '' OR name LIKE CONCAT('%', ?, '%'))
  AND (? IS NULL OR ? = '' OR department = ?)
  AND (? IS NULL OR ? = '' OR graduation_year = ?)
  AND (? IS NULL OR ? = '' OR company LIKE CONCAT('%', ?, '%'))
ORDER BY graduation_year DESC, name ASC;

-- 5) Jobs/internships report with search/filter
SELECT
    job_id,
    post_type,
    title,
    company,
    location,
    job_type,
    posted_date
FROM jobs
WHERE (? IS NULL OR ? = '' OR title LIKE CONCAT('%', ?, '%'))
  AND (? IS NULL OR ? = '' OR company LIKE CONCAT('%', ?, '%'))
  AND (? IS NULL OR ? = '' OR post_type = ?)
  AND (? IS NULL OR ? = '' OR location LIKE CONCAT('%', ?, '%'))
ORDER BY posted_date DESC, title ASC;
