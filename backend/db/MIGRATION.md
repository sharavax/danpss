# Migration instructions — DANPSS database

This file describes safe, repeatable steps to back up and run the migration SQL located at `backend/db/schema.sql`.

WARNING: Run these steps on a staging environment first and take a full backup before applying to production.

Prerequisites
- MySQL server accessible and the `mysql`/`mysqldump` client installed.
- Sufficient disk space for backups.
- A tested staging copy of the database (recommended).

1) Create a logical backup (dump)

Open a terminal (Windows `cmd`) and run:

```bat
cd \DANPSS\backend\db
set BACKUP=danpss_db_backup_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.sql
mysqldump -u root -p --single-transaction --routines --triggers danpss_db > "%BACKUP%"
```

Enter the MySQL password when prompted. Confirm the backup file exists.

2) Review the migration SQL

Open `backend/db/schema.sql` and inspect the migration section. The file contains:
- creation of compatibility tables (`users`, `students`, `jobs`),
- migration INSERT...SELECT statements from legacy tables (`student`, `job`, `internship`),
- updates to `application` and cleanup (drops legacy tables),
- FK/index additions.

If you prefer to run only parts of the migration, copy the relevant SQL snippets to a new file and run them selectively.

3) Run the migration (non-interactive)

From `cmd`:

```bat
cd \DANPSS\backend\db
mysql -u root -p danpss_db < schema.sql
```

This executes the SQL in `schema.sql`. If you have a different DB user or host, add `-h host` or change `-u` accordingly.

4) Verification queries

Connect to MySQL and run some checks:

```sql
USE danpss_db;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM students;
SELECT COUNT(*) FROM jobs;
SELECT COUNT(*) FROM application;
```

Check that `student`, `job`, `internship` tables are removed (if migration/drops succeeded).

5) Rollback

If needed, restore from the backup created earlier:

```bat
mysql -u root -p danpss_db < path\to\danpss_db_backup_YYYYMMDD.sql
```

6) Troubleshooting notes
- If `ALTER TABLE ... ADD CONSTRAINT` fails due to existing data violating FK rules, identify violating rows and fix or remove them before re-running.
- On older MySQL servers, `CREATE INDEX IF NOT EXISTS` may not be supported — run `SHOW INDEX FROM <table>` to check, or remove `IF NOT EXISTS` and guard in a script.
- If `mysqldump`/`mysql` are not in PATH on Windows, run them from the MySQL installation `bin` folder or add to PATH.

Contact
- If you want, I can produce a safe wrapper script (PowerShell or batch) that:
  - creates a timestamped backup,
  - runs migration into a transaction where possible,
  - logs output and errors.

---
Keep this README next to `schema.sql` for future reference.
