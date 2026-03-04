package com.danpss.servlets;

import com.danpss.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final String RULES_SQL = "SELECT rule_key, rule_value FROM matching_rules";
    private static final String STUDENT_SQL =
            "SELECT student_id, name, email, department, graduation_year, skills " +
            "FROM students WHERE email = ? ORDER BY student_id DESC LIMIT 1";
    private static final String JOBS_SQL =
            "SELECT job_id, post_type, title, company, location, job_type, eligibility, posted_date " +
            "FROM jobs ORDER BY posted_date DESC, job_id DESC";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.html");
            return;
        }

        String userEmail = String.valueOf(session.getAttribute("userEmail"));
        String userName = String.valueOf(session.getAttribute("userName"));
        String userRole = String.valueOf(session.getAttribute("userRole"));

        Rules rules = new Rules();
        StudentProfile student = null;
        List<Recommendation> recommendations = new ArrayList<Recommendation>();

        try (Connection con = DBUtil.getConnection()) {
            loadRules(con, rules);
            student = loadStudent(con, userEmail);
            if (student != null) {
                recommendations = buildRecommendations(con, student, rules);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("userName", userName);
        req.setAttribute("userRole", userRole);
        req.setAttribute("student", student);
        req.setAttribute("recommendations", recommendations);
        req.setAttribute("rules", rules);
        req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
    }

    private void loadRules(Connection con, Rules rules) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(RULES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("rule_key");
                String value = rs.getString("rule_value");
                if ("skills_weight".equals(key)) {
                    rules.skillsWeight = parseDouble(value, rules.skillsWeight);
                } else if ("eligibility_weight".equals(key)) {
                    rules.eligibilityWeight = parseDouble(value, rules.eligibilityWeight);
                } else if ("graduation_year_weight".equals(key)) {
                    rules.gradYearWeight = parseDouble(value, rules.gradYearWeight);
                } else if ("minimum_match_score".equals(key)) {
                    rules.minScore = parseDouble(value, rules.minScore);
                } else if ("max_recommendations".equals(key)) {
                    rules.maxRecommendations = parseInt(value, rules.maxRecommendations);
                }
            }
        } catch (Exception ignored) {
            // Defaults are used if table is absent or not configured.
        }
    }

    private StudentProfile loadStudent(Connection con, String email) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(STUDENT_SQL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                StudentProfile s = new StudentProfile();
                s.studentId = rs.getInt("student_id");
                s.name = nv(rs.getString("name"));
                s.email = nv(rs.getString("email"));
                s.department = nv(rs.getString("department"));
                s.graduationYear = rs.getInt("graduation_year");
                s.skills = nv(rs.getString("skills"));
                return s;
            }
        }
    }

    private List<Recommendation> buildRecommendations(Connection con, StudentProfile student, Rules rules) throws Exception {
        List<Recommendation> rows = new ArrayList<Recommendation>();
        String[] skillTokens = splitSkills(student.skills);

        try (PreparedStatement ps = con.prepareStatement(JOBS_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String eligibility = nv(rs.getString("eligibility"));
                String searchable = (
                        nv(rs.getString("title")) + " " +
                        nv(rs.getString("job_type")) + " " +
                        nv(rs.getString("post_type")) + " " +
                        eligibility
                ).toLowerCase();

                int matchedSkills = 0;
                for (String skill : skillTokens) {
                    if (!skill.isEmpty() && searchable.contains(skill)) {
                        matchedSkills++;
                    }
                }

                double skillsScore = skillTokens.length == 0 ? 0.0 : (double) matchedSkills / (double) skillTokens.length;
                double eligibilityScore = evaluateEligibility(student.department, eligibility);
                double gradYearScore = evaluateGraduationYear(student.graduationYear, eligibility);
                double score = (skillsScore * rules.skillsWeight)
                        + (eligibilityScore * rules.eligibilityWeight)
                        + (gradYearScore * rules.gradYearWeight);

                if (score >= rules.minScore) {
                    Recommendation r = new Recommendation();
                    r.jobId = rs.getInt("job_id");
                    r.postType = nv(rs.getString("post_type"));
                    r.title = nv(rs.getString("title"));
                    r.company = nv(rs.getString("company"));
                    r.location = nv(rs.getString("location"));
                    r.jobType = nv(rs.getString("job_type"));
                    r.score = score;
                    r.reason = "skills " + matchedSkills + "/" + skillTokens.length
                            + ", eligibility " + asPercent(eligibilityScore)
                            + ", grad-year " + asPercent(gradYearScore);
                    rows.add(r);
                }
            }
        }

        rows.sort((a, b) -> Double.compare(b.score, a.score));
        if (rows.size() > rules.maxRecommendations) {
            return new ArrayList<Recommendation>(rows.subList(0, rules.maxRecommendations));
        }
        return rows;
    }

    private double evaluateEligibility(String department, String eligibility) {
        String e = nv(eligibility).toLowerCase();
        String d = nv(department).toLowerCase();
        if (e.isEmpty()) {
            return 0.50;
        }
        if (e.contains("any") || e.contains("all") || e.contains("open")) {
            return 1.0;
        }
        if (!d.isEmpty() && e.contains(d)) {
            return 1.0;
        }
        return 0.0;
    }

    private double evaluateGraduationYear(int graduationYear, String eligibility) {
        if (graduationYear <= 0) {
            return 0.50;
        }
        String e = nv(eligibility).toLowerCase();
        if (e.isEmpty()) {
            return 0.50;
        }
        String year = String.valueOf(graduationYear);
        if (e.contains(year)) {
            return 1.0;
        }
        if (e.contains("any year") || e.contains("all year") || e.contains("all batch")) {
            return 1.0;
        }
        return 0.0;
    }

    private String[] splitSkills(String skills) {
        String raw = nv(skills).toLowerCase();
        if (raw.isEmpty()) {
            return new String[0];
        }
        String[] parts = raw.split("[,;/| ]+");
        List<String> tokens = new ArrayList<String>();
        for (String part : parts) {
            String t = part.trim();
            if (!t.isEmpty()) {
                tokens.add(t);
            }
        }
        return tokens.toArray(new String[0]);
    }

    private String asPercent(double value) {
        return String.format("%.0f%%", value * 100.0);
    }

    private String nv(String value) {
        return value == null ? "" : value.trim();
    }

    private double parseDouble(String value, double fallback) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    public static class Rules {
        public double skillsWeight = 0.50;
        public double eligibilityWeight = 0.30;
        public double gradYearWeight = 0.20;
        public double minScore = 0.45;
        public int maxRecommendations = 10;
    }

    public static class StudentProfile {
        public int studentId;
        public String name;
        public String email;
        public String department;
        public int graduationYear;
        public String skills;
    }

    public static class Recommendation {
        public int jobId;
        public String postType;
        public String title;
        public String company;
        public String location;
        public String jobType;
        public double score;
        public String reason;
    }
}
