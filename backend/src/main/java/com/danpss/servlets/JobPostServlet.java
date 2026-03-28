package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.LookupUtil;
import com.danpss.util.AccessControlUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "JobPostServlet", urlPatterns = {"/job/post"})
public class JobPostServlet extends HttpServlet {
    private static final String INSERT_OPPORTUNITY_SQL =
            "INSERT INTO opportunities (post_type_id, title, company_id, location_id, employment_type_id, duration_months, stipend_amount, stipend_currency, eligibility_notes, posted_date) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)";
    private static final String INSERT_OPPORTUNITY_SKILL_SQL =
            "INSERT INTO opportunity_skills (opportunity_id, skill_id) VALUES (?, ?)";
    private static final String INSERT_OPPORTUNITY_DEPARTMENT_SQL =
            "INSERT INTO opportunity_departments (opportunity_id, department_id) VALUES (?, ?)";
    private static final String INSERT_OPPORTUNITY_YEAR_SQL =
            "INSERT INTO opportunity_graduation_years (opportunity_id, graduation_year) VALUES (?, ?)";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (AccessControlUtil.requireRole(req, resp, "Alumni", "Placement Officer") == null) {
            return;
        }
        req.setCharacterEncoding("UTF-8");

        String postType = normalize(req.getParameter("jobPostType"));
        String title = normalize(req.getParameter("jobTitle"));
        String company = normalize(req.getParameter("jobCompany"));
        String location = normalize(req.getParameter("jobLocation"));
        String employmentType = normalize(req.getParameter("jobJobType"));
        String eligibility = normalize(req.getParameter("jobEligibility"));
        String duration = normalize(req.getParameter("jobDuration"));
        String stipend = normalize(req.getParameter("jobStipend"));
        String postedDate = normalize(req.getParameter("jobPostedDate"));
        String[] departmentChoices = req.getParameterValues("jobDepartmentChoice");
        String[] graduationYearChoices = req.getParameterValues("jobYearChoice");
        String[] skillChoices = req.getParameterValues("jobSkillChoice");

        if (postType.isEmpty() || title.isEmpty() || company.isEmpty() || location.isEmpty()
                || employmentType.isEmpty() || postedDate.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/jobpost.html?error=missing_fields");
            return;
        }
        if (!"Job".equals(postType) && !"Internship".equals(postType)) {
            resp.sendRedirect(req.getContextPath() + "/jobpost.html?error=invalid_post_type");
            return;
        }
        if (!isValidDate(postedDate)) {
            resp.sendRedirect(req.getContextPath() + "/jobpost.html?error=invalid_date");
            return;
        }
        if ("Internship".equals(postType)) {
            int durationMonths = parseInt(duration, -1);
            if (durationMonths <= 0) {
                resp.sendRedirect(req.getContextPath() + "/jobpost.html?error=invalid_duration");
                return;
            }
            if (parseMoney(stipend) == null) {
                resp.sendRedirect(req.getContextPath() + "/jobpost.html?error=missing_internship_fields");
                return;
            }
        }

        Set<String> departments = collectDistinctValues(departmentChoices);
        Set<Integer> graduationYears = collectDistinctYears(graduationYearChoices);
        Set<String> skills = collectDistinctValues(skillChoices);

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);

            int postTypeId = LookupUtil.findOrCreateByName(con, "post_types", "post_type_id", "post_type_name", postType);
            int companyId = LookupUtil.findOrCreateByName(con, "companies", "company_id", "company_name", company);
            int locationId = LookupUtil.findOrCreateByName(con, "locations", "location_id", "location_name", location);
            int employmentTypeId = LookupUtil.findOrCreateByName(con, "employment_types", "employment_type_id", "employment_type_name", employmentType);

            Integer opportunityId = null;
            try (PreparedStatement ps = con.prepareStatement(INSERT_OPPORTUNITY_SQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, postTypeId);
                ps.setString(2, title);
                ps.setInt(3, companyId);
                ps.setInt(4, locationId);
                ps.setInt(5, employmentTypeId);
                if (duration.isEmpty()) {
                    ps.setNull(6, java.sql.Types.INTEGER);
                } else {
                    ps.setInt(6, Integer.parseInt(duration));
                }
                BigDecimal stipendAmount = parseMoney(stipend);
                if (stipendAmount == null) {
                    ps.setNull(7, java.sql.Types.DECIMAL);
                    ps.setNull(8, java.sql.Types.CHAR);
                } else {
                    ps.setBigDecimal(7, stipendAmount);
                    ps.setString(8, "INR");
                }
                ps.setString(9, eligibility);
                ps.setString(10, postedDate);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        opportunityId = Integer.valueOf(rs.getInt(1));
                    }
                }
            }

            if (opportunityId == null) {
                throw new IllegalStateException("Unable to create opportunity.");
            }

            for (String department : departments) {
                int departmentId = LookupUtil.findOrCreateByName(con, "departments", "department_id", "department_name", department);
                try (PreparedStatement ps = con.prepareStatement(INSERT_OPPORTUNITY_DEPARTMENT_SQL)) {
                    ps.setInt(1, opportunityId.intValue());
                    ps.setInt(2, departmentId);
                    ps.executeUpdate();
                }
            }

            for (Integer year : graduationYears) {
                try (PreparedStatement ps = con.prepareStatement(INSERT_OPPORTUNITY_YEAR_SQL)) {
                    ps.setInt(1, opportunityId.intValue());
                    ps.setInt(2, year.intValue());
                    ps.executeUpdate();
                }
            }

            for (String token : skills) {
                int skillId = LookupUtil.findOrCreateByName(con, "skills", "skill_id", "skill_name", token);
                try (PreparedStatement ps = con.prepareStatement(INSERT_OPPORTUNITY_SKILL_SQL)) {
                    ps.setInt(1, opportunityId.intValue());
                    ps.setInt(2, skillId);
                    ps.executeUpdate();
                }
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/reports/jobs?success=job_posted");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private BigDecimal parseMoney(String stipend) {
        if (stipend == null || stipend.trim().isEmpty()) {
            return null;
        }
        String digits = stipend.replaceAll("[^0-9.]", "");
        if (digits.isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(digits);
        } catch (Exception e) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private boolean isValidDate(String value) {
        try {
            java.time.LocalDate.parse(value);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Set<String> collectDistinctValues(String[] values) {
        Set<String> result = new LinkedHashSet<String>();
        if (values == null) {
            return result;
        }
        for (int i = 0; i < values.length; i++) {
            String value = normalize(values[i]);
            if (!value.isEmpty()) {
                result.add(value);
            }
        }
        return result;
    }

    private Set<Integer> collectDistinctYears(String[] values) {
        Set<Integer> result = new LinkedHashSet<Integer>();
        if (values == null) {
            return result;
        }
        for (int i = 0; i < values.length; i++) {
            int year = parseInt(values[i], -1);
            if (year >= 1990 && year <= 2100) {
                result.add(Integer.valueOf(year));
            }
        }
        return result;
    }
}
