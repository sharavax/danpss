# DANPSS Java Backend (Tomcat)

Quick steps to build and deploy the backend on Tomcat:

1. Edit DB config in `backend/src/main/resources/db.properties`.
2. Create database and tables by running `backend/db/schema.sql` on MySQL.
3. Build WAR:

```bash
cd backend
mvn package
```

4. Deploy `target/danpss.war` to Tomcat `webapps/` (or deploy via Tomcat Manager).
5. Access app at `http://localhost:8080/danpss/`.

## Endpoints

POST:
- `/register` - generic registration (from `register.html`)
- `/login` - login form
- `/alumni/register` - alumni registration
- `/student/profile` - student profile creation
- `/job/post` - job/internship posting

GET:
- `/reports/placement` - JSP placement analytics report with search/filter (`search`, `department`, `graduationYear`, `company`)
- `/reports/jobs` - JSP jobs/internship report with search/filter (`title`, `company`, `postType`, `location`)
- `/dashboard` - personalized dashboard with recommendation matching rules (skills, eligibility, graduation year)

## SQL Analytics

- `backend/db/placement_analytics.sql` includes reusable placement analytics and report queries.
- `backend/db/schema.sql` includes `matching_rules` seed values used by recommendation logic.

## Notes

- This is a minimal JDBC demo using `DriverManager`.
- For production, use a connection pool and hashed passwords.
