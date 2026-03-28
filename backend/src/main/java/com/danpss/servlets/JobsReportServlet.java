package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.AccessControlUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "JobsReportServlet", urlPatterns = {"/reports/jobs"})
public class JobsReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (AccessControlUtil.requireRole(req, resp, "Student", "Alumni", "Placement Officer") == null) {
            return;
        }
        String title = normalize(req.getParameter("title"));
        String company = normalize(req.getParameter("company"));
        String postType = normalize(req.getParameter("postType"));
        String jobType = normalize(req.getParameter("jobType"));
        String location = normalize(req.getParameter("location"));

        List<String[]> rows = new ArrayList<String[]>();

        String sql =
                "SELECT o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, et.employment_type_name, " +
                "COALESCE(o.eligibility_notes, '') AS eligibility_notes, o.duration_months, " +
                "CASE WHEN o.stipend_amount IS NULL THEN '' ELSE CONCAT(TRIM(TRAILING '.00' FROM CAST(o.stipend_amount AS CHAR)), IFNULL(CONCAT(' ', o.stipend_currency), '')) END AS stipend, " +
                "o.posted_date, " +
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
                "WHERE (? = '' OR o.title LIKE CONCAT('%', ?, '%')) " +
                "AND (? = '' OR c.company_name LIKE CONCAT('%', ?, '%')) " +
                "AND (? = '' OR pt.post_type_name = ?) " +
                "AND (? = '' OR et.employment_type_name = ?) " +
                "AND (? = '' OR l.location_name LIKE CONCAT('%', ?, '%')) " +
                "GROUP BY o.opportunity_id, pt.post_type_name, o.title, c.company_name, l.location_name, et.employment_type_name, o.eligibility_notes, o.duration_months, o.stipend_amount, o.stipend_currency, o.posted_date " +
                "ORDER BY o.posted_date DESC, o.opportunity_id DESC";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, title);
            ps.setString(3, company);
            ps.setString(4, company);
            ps.setString(5, postType);
            ps.setString(6, postType);
            ps.setString(7, jobType);
            ps.setString(8, jobType);
            ps.setString(9, location);
            ps.setString(10, location);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new String[]{
                            String.valueOf(rs.getInt("opportunity_id")),
                            rs.getString("post_type_name"),
                            rs.getString("title"),
                            rs.getString("company_name"),
                            rs.getString("location_name"),
                            rs.getString("employment_type_name"),
                            buildEligibility(rs.getString("eligibility_notes"), rs.getString("departments"), rs.getString("years"), rs.getString("skills")),
                            blankIfZero(rs.getInt("duration_months")),
                            normalize(rs.getString("stipend")),
                            String.valueOf(rs.getDate("posted_date"))
                    });
                }
            }

            req.setAttribute("title", title);
            req.setAttribute("company", company);
            req.setAttribute("postType", postType);
            req.setAttribute("jobType", jobType);
            req.setAttribute("location", location);
            req.setAttribute("rows", rows);
            req.setAttribute("resultCount", rows.size());
            req.setAttribute("totalJobs", countByPostType(con, "Job"));
            req.setAttribute("totalInternships", countByPostType(con, "Internship"));
            req.setAttribute("hiringCompanies", countCompanies(con));
            req.getRequestDispatcher("/reports/jobs-report.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
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

    private String buildEligibility(String notes, String departments, String years, String skills) {
        List<String> parts = new ArrayList<String>();
        if (!normalize(notes).isEmpty()) {
            parts.add(normalize(notes));
        }
        if (!normalize(departments).isEmpty()) {
            parts.add("Departments: " + departments);
        }
        if (!normalize(years).isEmpty()) {
            parts.add("Years: " + years);
        }
        if (!normalize(skills).isEmpty()) {
            parts.add("Skills: " + skills);
        }
        if (parts.isEmpty()) {
            return "Open opportunity";
        }
        return join(parts, " | ");
    }

    private String join(List<String> parts, String separator) {
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < parts.size(); i++) {
            if (i > 0) {
                builder.append(separator);
            }
            builder.append(parts.get(i));
        }
        return builder.toString();
    }

    private String blankIfZero(int value) {
        return value <= 0 ? "" : String.valueOf(value);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
