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

@WebServlet(name = "PlacementOfficerDashboardServlet", urlPatterns = {"/dashboard/officer"})
public class PlacementOfficerDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = AccessControlUtil.requireRole(req, resp, "Placement Officer");
        if (session == null) {
            return;
        }

        OfficerSummary summary = new OfficerSummary();
        List<StudentRow> students = new ArrayList<StudentRow>();
        List<JobRow> jobs = new ArrayList<JobRow>();
        MatchingRules rules = new MatchingRules();

        try (Connection con = DBUtil.getConnection()) {
            loadSummary(con, summary);
            loadStudents(con, students);
            loadJobs(con, jobs);
            loadRules(con, rules);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("userName", String.valueOf(session.getAttribute("userName")));
        req.setAttribute("userRole", String.valueOf(session.getAttribute("userRole")));
        req.setAttribute("userEmail", String.valueOf(session.getAttribute("userEmail")));
        req.setAttribute("summary", summary);
        req.setAttribute("students", students);
        req.setAttribute("jobs", jobs);
        req.setAttribute("rules", rules);
        req.getRequestDispatcher("/dashboards/officer-dashboard.jsp").forward(req, resp);
    }

    private void loadSummary(Connection con, OfficerSummary summary) throws Exception {
        summary.totalUsers = count(con, "SELECT COUNT(*) FROM users");
        summary.totalStudents = count(con, "SELECT COUNT(*) FROM students");
        summary.totalAlumni = count(con, "SELECT COUNT(*) FROM alumni");
        summary.totalJobs = count(con, "SELECT COUNT(*) FROM opportunities");
        summary.placedStudents = count(con, "SELECT COUNT(*) FROM students WHERE current_company_id IS NOT NULL");
        summary.placementRate = summary.totalStudents == 0 ? 0.0 : (summary.placedStudents * 100.0) / summary.totalStudents;
    }

    private int count(Connection con, String sql) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private void loadStudents(Connection con, List<StudentRow> rows) throws Exception {
        String sql =
                "SELECT s.student_id, u.full_name, d.department_name, s.graduation_year, " +
                "COALESCE(GROUP_CONCAT(DISTINCT sk.skill_name ORDER BY sk.skill_name SEPARATOR ', '), '') AS skills " +
                "FROM students s " +
                "JOIN users u ON u.user_id = s.user_id " +
                "JOIN departments d ON d.department_id = s.department_id " +
                "LEFT JOIN student_skills ss ON ss.student_id = s.student_id " +
                "LEFT JOIN skills sk ON sk.skill_id = ss.skill_id " +
                "GROUP BY s.student_id, u.full_name, d.department_name, s.graduation_year " +
                "ORDER BY s.student_id DESC LIMIT 5";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                StudentRow row = new StudentRow();
                row.studentId = rs.getInt("student_id");
                row.name = rs.getString("full_name");
                row.department = rs.getString("department_name");
                row.graduationYear = rs.getInt("graduation_year");
                row.skills = rs.getString("skills");
                rows.add(row);
            }
        }
    }

    private void loadJobs(Connection con, List<JobRow> rows) throws Exception {
        String sql =
                "SELECT o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, o.posted_date " +
                "FROM opportunities o " +
                "JOIN post_types pt ON pt.post_type_id = o.post_type_id " +
                "JOIN companies c ON c.company_id = o.company_id " +
                "JOIN locations l ON l.location_id = o.location_id " +
                "ORDER BY o.posted_date DESC, o.opportunity_id DESC LIMIT 5";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                JobRow row = new JobRow();
                row.jobId = rs.getInt("opportunity_id");
                row.postType = rs.getString("post_type_name");
                row.title = rs.getString("title");
                row.company = rs.getString("company_name");
                row.location = rs.getString("location_name");
                row.postedDate = String.valueOf(rs.getDate("posted_date"));
                rows.add(row);
            }
        }
    }

    private void loadRules(Connection con, MatchingRules rules) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("SELECT rule_key, rule_value FROM matching_rules");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("rule_key");
                String value = rs.getString("rule_value");
                if ("skills_weight".equals(key)) {
                    rules.skillsWeight = value;
                } else if ("eligibility_weight".equals(key)) {
                    rules.eligibilityWeight = value;
                } else if ("graduation_year_weight".equals(key)) {
                    rules.gradYearWeight = value;
                } else if ("minimum_match_score".equals(key)) {
                    rules.minScore = value;
                } else if ("max_recommendations".equals(key)) {
                    rules.maxRecommendations = value;
                }
            }
        }
    }

    public static class OfficerSummary {
        public int totalUsers;
        public int totalStudents;
        public int totalAlumni;
        public int totalJobs;
        public int placedStudents;
        public double placementRate;
    }

    public static class StudentRow {
        public int studentId;
        public String name;
        public String department;
        public int graduationYear;
        public String skills;
    }

    public static class JobRow {
        public int jobId;
        public String postType;
        public String title;
        public String company;
        public String location;
        public String postedDate;
    }

    public static class MatchingRules {
        public String skillsWeight = "0.50";
        public String eligibilityWeight = "0.30";
        public String gradYearWeight = "0.20";
        public String minScore = "0.45";
        public String maxRecommendations = "10";
    }
}
