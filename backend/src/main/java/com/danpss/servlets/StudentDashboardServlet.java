package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.AccessControlUtil;

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

@WebServlet(name = "StudentDashboardServlet", urlPatterns = {"/dashboard/student"})
public class StudentDashboardServlet extends HttpServlet {
    private static final String RULES_SQL = "SELECT rule_key, rule_value FROM matching_rules";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = AccessControlUtil.requireRole(req, resp, "Student");
        if (session == null) {
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
        req.setAttribute("userEmail", userEmail);
        req.setAttribute("student", student);
        req.setAttribute("recommendations", recommendations);
        req.setAttribute("recommendationCount", recommendations.size());
        req.setAttribute("recommendationAverage", calculateAverageScore(recommendations));
        req.setAttribute("rules", rules);
        req.getRequestDispatcher("/dashboards/student-dashboard.jsp").forward(req, resp);
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
        }
    }

    private StudentProfile loadStudent(Connection con, String email) throws Exception {
        String sql =
                "SELECT s.student_id, u.full_name, u.email, d.department_name, s.graduation_year, " +
                "COALESCE(GROUP_CONCAT(DISTINCT sk.skill_name ORDER BY sk.skill_name SEPARATOR ', '), '') AS skills " +
                "FROM students s " +
                "JOIN users u ON u.user_id = s.user_id " +
                "JOIN departments d ON d.department_id = s.department_id " +
                "LEFT JOIN student_skills ss ON ss.student_id = s.student_id " +
                "LEFT JOIN skills sk ON sk.skill_id = ss.skill_id " +
                "WHERE u.email = ? " +
                "GROUP BY s.student_id, u.full_name, u.email, d.department_name, s.graduation_year";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                StudentProfile profile = new StudentProfile();
                profile.studentId = rs.getInt("student_id");
                profile.name = rs.getString("full_name");
                profile.email = rs.getString("email");
                profile.department = rs.getString("department_name");
                profile.graduationYear = rs.getInt("graduation_year");
                profile.skills = rs.getString("skills");
                return profile;
            }
        }
    }

    private List<Recommendation> buildRecommendations(Connection con, StudentProfile student, Rules rules) throws Exception {
        List<Recommendation> rows = new ArrayList<Recommendation>();
        String[] studentSkills = splitCsv(student.skills);

        String sql =
                "SELECT o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, et.employment_type_name, o.posted_date, " +
                "COALESCE(o.eligibility_notes, '') AS eligibility_notes, " +
                "COALESCE(GROUP_CONCAT(DISTINCT d.department_name ORDER BY d.department_name SEPARATOR ', '), '') AS departments, " +
                "COALESCE(GROUP_CONCAT(DISTINCT ogy.graduation_year ORDER BY ogy.graduation_year SEPARATOR ', '), '') AS years, " +
                "COALESCE(GROUP_CONCAT(DISTINCT sk.skill_name ORDER BY sk.skill_name SEPARATOR ', '), '') AS skills " +
                "FROM opportunities o " +
                "JOIN post_types pt ON pt.post_type_id = o.post_type_id " +
                "JOIN companies c ON c.company_id = o.company_id " +
                "JOIN locations l ON l.location_id = o.location_id " +
                "JOIN employment_types et ON et.employment_type_id = o.employment_type_id " +
                "LEFT JOIN opportunity_departments od ON od.opportunity_id = o.opportunity_id " +
                "LEFT JOIN departments d ON d.department_id = od.department_id " +
                "LEFT JOIN opportunity_graduation_years ogy ON ogy.opportunity_id = o.opportunity_id " +
                "LEFT JOIN opportunity_skills os ON os.opportunity_id = o.opportunity_id " +
                "LEFT JOIN skills sk ON sk.skill_id = os.skill_id " +
                "GROUP BY o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, et.employment_type_name, o.posted_date, o.eligibility_notes " +
                "ORDER BY o.posted_date DESC, o.opportunity_id DESC";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Recommendation recommendation = new Recommendation();
                recommendation.jobId = rs.getInt("opportunity_id");
                recommendation.postType = rs.getString("post_type_name");
                recommendation.title = rs.getString("title");
                recommendation.company = rs.getString("company_name");
                recommendation.location = rs.getString("location_name");
                recommendation.jobType = rs.getString("employment_type_name");
                recommendation.postedDate = String.valueOf(rs.getDate("posted_date"));

                String opportunitySkills = rs.getString("skills");
                recommendation.skillsScore = calculateSkillsScore(studentSkills, splitCsv(opportunitySkills));
                recommendation.eligibilityScore = calculateDepartmentScore(student.department, rs.getString("departments"), rs.getString("eligibility_notes"));
                recommendation.gradYearScore = calculateYearScore(student.graduationYear, rs.getString("years"));
                recommendation.score = (recommendation.skillsScore * rules.skillsWeight)
                        + (recommendation.eligibilityScore * rules.eligibilityWeight)
                        + (recommendation.gradYearScore * rules.gradYearWeight);
                recommendation.reason = buildReason(opportunitySkills, rs.getString("departments"), rs.getString("years"), rs.getString("eligibility_notes"));

                if (recommendation.score >= rules.minScore) {
                    rows.add(recommendation);
                }
            }
        }

        rows.sort((left, right) -> Double.compare(right.score, left.score));
        if (rows.size() > rules.maxRecommendations) {
            return new ArrayList<Recommendation>(rows.subList(0, rules.maxRecommendations));
        }
        return rows;
    }

    private double calculateSkillsScore(String[] studentSkills, String[] opportunitySkills) {
        if (studentSkills.length == 0 || opportunitySkills.length == 0) {
            return 0.5;
        }
        int matches = 0;
        for (int i = 0; i < studentSkills.length; i++) {
            for (int j = 0; j < opportunitySkills.length; j++) {
                if (studentSkills[i].equalsIgnoreCase(opportunitySkills[j])) {
                    matches++;
                    break;
                }
            }
        }
        return (double) matches / (double) studentSkills.length;
    }

    private double calculateDepartmentScore(String studentDepartment, String opportunityDepartments, String notes) {
        if (normalize(opportunityDepartments).isEmpty()) {
            String lowered = normalize(notes).toLowerCase();
            if (lowered.contains("all departments") || lowered.contains("any department")) {
                return 1.0;
            }
            return 0.5;
        }
        String[] departments = splitCsv(opportunityDepartments);
        for (int i = 0; i < departments.length; i++) {
            if (studentDepartment.equalsIgnoreCase(departments[i])) {
                return 1.0;
            }
        }
        return 0.0;
    }

    private double calculateYearScore(int studentYear, String years) {
        if (normalize(years).isEmpty()) {
            return 0.5;
        }
        String[] allowed = splitCsv(years);
        for (int i = 0; i < allowed.length; i++) {
            if (String.valueOf(studentYear).equals(allowed[i])) {
                return 1.0;
            }
        }
        return 0.0;
    }

    private String buildReason(String skills, String departments, String years, String notes) {
        List<String> reasons = new ArrayList<String>();
        if (!normalize(skills).isEmpty()) {
            reasons.add("Skills: " + skills);
        }
        if (!normalize(departments).isEmpty()) {
            reasons.add("Departments: " + departments);
        }
        if (!normalize(years).isEmpty()) {
            reasons.add("Years: " + years);
        }
        if (!normalize(notes).isEmpty()) {
            reasons.add(notes);
        }
        return reasons.isEmpty() ? "Matched on general criteria." : String.join(" | ", reasons);
    }

    private String[] splitCsv(String value) {
        String cleaned = normalize(value);
        if (cleaned.isEmpty()) {
            return new String[0];
        }
        String[] parts = cleaned.split("\\s*,\\s*");
        List<String> tokens = new ArrayList<String>();
        for (int i = 0; i < parts.length; i++) {
            String token = normalize(parts[i]);
            if (!token.isEmpty()) {
                tokens.add(token);
            }
        }
        return tokens.toArray(new String[0]);
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

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private double calculateAverageScore(List<Recommendation> recommendations) {
        if (recommendations == null || recommendations.isEmpty()) {
            return 0.0d;
        }
        double total = 0.0d;
        for (int i = 0; i < recommendations.size(); i++) {
            total += recommendations.get(i).score;
        }
        return total / recommendations.size();
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
        public String postedDate;
        public double score;
        public double skillsScore;
        public double eligibilityScore;
        public double gradYearScore;
        public String reason;
    }
}
