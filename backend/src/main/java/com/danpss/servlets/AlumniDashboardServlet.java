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

@WebServlet(name = "AlumniDashboardServlet", urlPatterns = {"/dashboard/alumni"})
public class AlumniDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = AccessControlUtil.requireRole(req, resp, "Alumni");
        if (session == null) {
            return;
        }

        String email = String.valueOf(session.getAttribute("userEmail"));
        AlumniProfile profile = null;
        List<Opportunity> opportunities = new ArrayList<Opportunity>();

        try (Connection con = DBUtil.getConnection()) {
            profile = loadProfile(con, email);
            loadOpportunities(con, opportunities);
            req.setAttribute("totalJobs", countByPostType(con, "Job"));
            req.setAttribute("totalInternships", countByPostType(con, "Internship"));
            req.setAttribute("hiringCompanies", countCompanies(con));
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("userName", String.valueOf(session.getAttribute("userName")));
        req.setAttribute("userRole", String.valueOf(session.getAttribute("userRole")));
        req.setAttribute("userEmail", email);
        req.setAttribute("profile", profile);
        req.setAttribute("opportunities", opportunities);
        req.getRequestDispatcher("/dashboards/alumni-dashboard.jsp").forward(req, resp);
    }

    private AlumniProfile loadProfile(Connection con, String email) throws Exception {
        String sql =
                "SELECT u.full_name, d.department_name, a.graduation_year, c.company_name, des.designation_name, a.experience_years " +
                "FROM alumni a " +
                "JOIN users u ON u.user_id = a.user_id " +
                "JOIN departments d ON d.department_id = a.department_id " +
                "JOIN companies c ON c.company_id = a.company_id " +
                "JOIN designations des ON des.designation_id = a.designation_id " +
                "WHERE u.email = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                AlumniProfile profile = new AlumniProfile();
                profile.name = rs.getString("full_name");
                profile.department = rs.getString("department_name");
                profile.graduationYear = rs.getInt("graduation_year");
                profile.company = rs.getString("company_name");
                profile.designation = rs.getString("designation_name");
                profile.experience = rs.getInt("experience_years");
                return profile;
            }
        }
    }

    private void loadOpportunities(Connection con, List<Opportunity> rows) throws Exception {
        String sql =
                "SELECT o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, et.employment_type_name, o.posted_date " +
                "FROM opportunities o " +
                "JOIN post_types pt ON pt.post_type_id = o.post_type_id " +
                "JOIN companies c ON c.company_id = o.company_id " +
                "JOIN locations l ON l.location_id = o.location_id " +
                "JOIN employment_types et ON et.employment_type_id = o.employment_type_id " +
                "ORDER BY o.posted_date DESC, o.opportunity_id DESC LIMIT 8";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Opportunity opportunity = new Opportunity();
                opportunity.jobId = rs.getInt("opportunity_id");
                opportunity.postType = rs.getString("post_type_name");
                opportunity.title = rs.getString("title");
                opportunity.company = rs.getString("company_name");
                opportunity.location = rs.getString("location_name");
                opportunity.jobType = rs.getString("employment_type_name");
                opportunity.postedDate = String.valueOf(rs.getDate("posted_date"));
                rows.add(opportunity);
            }
        }
    }

    private int countByPostType(Connection con, String postType) throws Exception {
        String sql = "SELECT COUNT(*) FROM opportunities o JOIN post_types pt ON pt.post_type_id = o.post_type_id WHERE pt.post_type_name = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, postType);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private int countCompanies(Connection con) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(DISTINCT company_id) FROM opportunities");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    public static class AlumniProfile {
        public String name;
        public String department;
        public int graduationYear;
        public String company;
        public String designation;
        public int experience;
    }

    public static class Opportunity {
        public int jobId;
        public String postType;
        public String title;
        public String company;
        public String location;
        public String jobType;
        public String postedDate;
    }
}
