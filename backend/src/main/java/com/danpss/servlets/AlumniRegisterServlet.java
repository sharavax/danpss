package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.LookupUtil;
import com.danpss.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet(name = "AlumniRegisterServlet", urlPatterns = {"/alumni/register"})
public class AlumniRegisterServlet extends HttpServlet {
    private static final String FIND_USER_SQL = "SELECT user_id FROM users WHERE email = ?";
    private static final String INSERT_USER_SQL =
            "INSERT INTO users (full_name, email, phone, password_hash, role_id) VALUES (?,?,?,?,?)";
    private static final String UPDATE_USER_SQL =
            "UPDATE users SET full_name = ?, phone = ?, password_hash = ?, role_id = ? WHERE user_id = ?";
    private static final String FIND_ALUMNI_SQL = "SELECT alumni_id FROM alumni WHERE user_id = ?";
    private static final String INSERT_ALUMNI_SQL =
            "INSERT INTO alumni (user_id, graduation_year, department_id, company_id, designation_id, experience_years) VALUES (?,?,?,?,?,?)";
    private static final String UPDATE_ALUMNI_SQL =
            "UPDATE alumni SET graduation_year = ?, department_id = ?, company_id = ?, designation_id = ?, experience_years = ? WHERE alumni_id = ?";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String name = normalize(req.getParameter("alumniName"));
        String email = normalize(req.getParameter("alumniEmail"));
        String phone = normalize(req.getParameter("alumniPhone"));
        String graduationYear = normalize(req.getParameter("alumniGraduationYear"));
        String department = normalize(req.getParameter("alumniDepartment"));
        String company = normalize(req.getParameter("alumniCompany"));
        String designation = normalize(req.getParameter("alumniDesignation"));
        String experience = normalize(req.getParameter("alumniExperience"));
        String pass = normalize(req.getParameter("alumniPass"));

        if (name.isEmpty() || email.isEmpty() || phone.isEmpty() || graduationYear.isEmpty()
                || department.isEmpty() || company.isEmpty() || designation.isEmpty()
                || experience.isEmpty() || pass.length() < 6) {
            resp.sendRedirect(req.getContextPath() + "/alumnireg.html?error=missing_fields");
            return;
        }
        if (!isValidEmail(email)) {
            resp.sendRedirect(req.getContextPath() + "/alumnireg.html?error=invalid_email");
            return;
        }
        if (!isValidPhone(phone)) {
            resp.sendRedirect(req.getContextPath() + "/alumnireg.html?error=invalid_phone");
            return;
        }
        int graduationYearValue = parseInt(graduationYear, -1);
        if (graduationYearValue < 1990 || graduationYearValue > 2100) {
            resp.sendRedirect(req.getContextPath() + "/alumnireg.html?error=invalid_graduation_year");
            return;
        }
        int experienceYears = parseInt(experience, -1);
        if (experienceYears < 0) {
            resp.sendRedirect(req.getContextPath() + "/alumnireg.html?error=invalid_experience");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);

            int roleId = LookupUtil.requireIdByName(con, "roles", "role_id", "role_name", "Alumni");
            Integer userId = findUserId(con, email);
            String passwordHash = PasswordUtil.hashPassword(pass);
            if (userId == null) {
                try (PreparedStatement ps = con.prepareStatement(INSERT_USER_SQL, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setString(3, phone);
                    ps.setString(4, passwordHash);
                    ps.setInt(5, roleId);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = Integer.valueOf(rs.getInt(1));
                        }
                    }
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(UPDATE_USER_SQL)) {
                    ps.setString(1, name);
                    ps.setString(2, phone);
                    ps.setString(3, passwordHash);
                    ps.setInt(4, roleId);
                    ps.setInt(5, userId.intValue());
                    ps.executeUpdate();
                }
            }

            if (userId == null) {
                throw new IllegalStateException("Unable to create or update alumni user.");
            }

            int departmentId = LookupUtil.findOrCreateByName(con, "departments", "department_id", "department_name", department);
            int companyId = LookupUtil.findOrCreateByName(con, "companies", "company_id", "company_name", company);
            int designationId = LookupUtil.findOrCreateByName(con, "designations", "designation_id", "designation_name", designation);

            Integer alumniId = findAlumniId(con, userId.intValue());
            if (alumniId == null) {
                try (PreparedStatement ps = con.prepareStatement(INSERT_ALUMNI_SQL)) {
                    ps.setInt(1, userId.intValue());
                    ps.setInt(2, graduationYearValue);
                    ps.setInt(3, departmentId);
                    ps.setInt(4, companyId);
                    ps.setInt(5, designationId);
                    ps.setInt(6, experienceYears);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(UPDATE_ALUMNI_SQL)) {
                    ps.setInt(1, graduationYearValue);
                    ps.setInt(2, departmentId);
                    ps.setInt(3, companyId);
                    ps.setInt(4, designationId);
                    ps.setInt(5, experienceYears);
                    ps.setInt(6, alumniId.intValue());
                    ps.executeUpdate();
                }
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/login.html?success=alumni_registered");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Integer findUserId(Connection con, String email) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(FIND_USER_SQL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Integer.valueOf(rs.getInt(1)) : null;
            }
        }
    }

    private Integer findAlumniId(Connection con, int userId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(FIND_ALUMNI_SQL)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Integer.valueOf(rs.getInt(1)) : null;
            }
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

    private boolean isValidEmail(String email) {
        return email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    private boolean isValidPhone(String phone) {
        return phone.matches("^\\d{10}$");
    }
}
