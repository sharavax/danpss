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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet(name = "StudentProfileServlet", urlPatterns = {"/student/profile"})
public class StudentProfileServlet extends HttpServlet {
    private static final String FIND_USER_SQL = "SELECT user_id FROM users WHERE email = ?";
    private static final String UPDATE_USER_SQL = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
    private static final String FIND_STUDENT_SQL = "SELECT student_id FROM students WHERE user_id = ?";
    private static final String INSERT_STUDENT_SQL =
            "INSERT INTO students (user_id, graduation_year, department_id, current_company_id, designation_id, experience_years) VALUES (?,?,?,?,?,?)";
    private static final String UPDATE_STUDENT_SQL =
            "UPDATE students SET graduation_year = ?, department_id = ?, current_company_id = ?, designation_id = ?, experience_years = ? WHERE student_id = ?";
    private static final String DELETE_SKILLS_SQL = "DELETE FROM student_skills WHERE student_id = ?";
    private static final String INSERT_SKILL_LINK_SQL = "INSERT INTO student_skills (student_id, skill_id) VALUES (?, ?)";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (AccessControlUtil.requireRole(req, resp, "Student") == null) {
            return;
        }
        req.setCharacterEncoding("UTF-8");

        String name = normalize(req.getParameter("studentName"));
        String email = normalize(req.getParameter("studentEmail"));
        String phone = normalize(req.getParameter("studentPhone"));
        String graduationYear = normalize(req.getParameter("studentGraduationYear"));
        String department = normalize(req.getParameter("studentDepartment"));
        String company = normalize(req.getParameter("studentCompany"));
        String designation = normalize(req.getParameter("studentDesignation"));
        String experience = normalize(req.getParameter("studentExperience"));
        String skills = normalize(req.getParameter("studentSkills"));

        if (name.isEmpty() || email.isEmpty() || department.isEmpty() || designation.isEmpty() || skills.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=missing_fields");
            return;
        }
        if (!isValidEmail(email)) {
            resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=invalid_email");
            return;
        }
        if (!phone.isEmpty() && !isValidPhone(phone)) {
            resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=invalid_phone");
            return;
        }
        int experienceYears = parseInt(experience, -1);
        if (!experience.isEmpty() && experienceYears < 0) {
            resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=invalid_experience");
            return;
        }
        Integer graduationYearValue = null;
        if (!graduationYear.isEmpty()) {
            int year = parseInt(graduationYear, -1);
            if (year < 1990 || year > 2100) {
                resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=invalid_graduation_year");
                return;
            }
            graduationYearValue = Integer.valueOf(year);
        }

        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);

            Integer userId = findUserId(con, email);
            if (userId == null) {
                con.rollback();
                resp.sendRedirect(req.getContextPath() + "/studentprofile.html?error=user_missing");
                return;
            }

            int departmentId = LookupUtil.findOrCreateByName(con, "departments", "department_id", "department_name", department);
            Integer companyId = company.isEmpty() ? null : Integer.valueOf(LookupUtil.findOrCreateByName(con, "companies", "company_id", "company_name", company));
            int designationId = LookupUtil.findOrCreateByName(con, "designations", "designation_id", "designation_name", designation);

            try (PreparedStatement ps = con.prepareStatement(UPDATE_USER_SQL)) {
                ps.setString(1, name);
                ps.setString(2, phone.isEmpty() ? "0000000000" : phone);
                ps.setInt(3, userId.intValue());
                ps.executeUpdate();
            }

            Integer studentId = findStudentId(con, userId.intValue());

            if (studentId == null) {
                try (PreparedStatement ps = con.prepareStatement(INSERT_STUDENT_SQL, Statement.RETURN_GENERATED_KEYS)) {
                    setNullableInt(ps, 1, userId.intValue());
                    setNullableInt(ps, 2, graduationYearValue);
                    ps.setInt(3, departmentId);
                    setNullableInt(ps, 4, companyId);
                    ps.setInt(5, designationId);
                    ps.setInt(6, experienceYears);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            studentId = Integer.valueOf(rs.getInt(1));
                        }
                    }
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(UPDATE_STUDENT_SQL)) {
                    setNullableInt(ps, 1, graduationYearValue);
                    ps.setInt(2, departmentId);
                    setNullableInt(ps, 3, companyId);
                    ps.setInt(4, designationId);
                    ps.setInt(5, experienceYears);
                    ps.setInt(6, studentId.intValue());
                    ps.executeUpdate();
                }
            }

            if (studentId == null) {
                throw new IllegalStateException("Unable to create student profile.");
            }

            try (PreparedStatement ps = con.prepareStatement(DELETE_SKILLS_SQL)) {
                ps.setInt(1, studentId.intValue());
                ps.executeUpdate();
            }

            String[] tokens = splitCommaSeparated(skills);
            for (int i = 0; i < tokens.length; i++) {
                int skillId = LookupUtil.findOrCreateByName(con, "skills", "skill_id", "skill_name", tokens[i].toLowerCase());
                try (PreparedStatement ps = con.prepareStatement(INSERT_SKILL_LINK_SQL)) {
                    ps.setInt(1, studentId.intValue());
                    ps.setInt(2, skillId);
                    ps.executeUpdate();
                }
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/dashboard/student");
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

    private Integer findStudentId(Connection con, int userId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(FIND_STUDENT_SQL)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Integer.valueOf(rs.getInt(1)) : null;
            }
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws Exception {
        if (value == null) {
            ps.setNull(index, java.sql.Types.INTEGER);
        } else {
            ps.setInt(index, value.intValue());
        }
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private String[] splitCommaSeparated(String value) {
        String[] raw = value.split(",");
        java.util.List<String> cleaned = new java.util.ArrayList<String>();
        for (int i = 0; i < raw.length; i++) {
            String token = raw[i] == null ? "" : raw[i].trim();
            if (!token.isEmpty() && !cleaned.contains(token)) {
                cleaned.add(token);
            }
        }
        return cleaned.toArray(new String[0]);
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
