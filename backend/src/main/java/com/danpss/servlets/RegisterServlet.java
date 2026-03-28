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
import java.sql.SQLIntegrityConstraintViolationException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private static final String FIND_USER_SQL = "SELECT user_id FROM users WHERE email = ?";
    private static final String INSERT_USER_SQL =
            "INSERT INTO users (full_name, email, phone, password_hash, role_id) VALUES (?,?,?,?,?)";
    private static final String UPDATE_USER_SQL =
            "UPDATE users SET full_name = ?, phone = ?, password_hash = ?, role_id = ? WHERE user_id = ?";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String name = normalize(req.getParameter("regName"));
        String roleName = normalize(req.getParameter("role"));
        String email = normalize(req.getParameter("regEmail"));
        String phone = normalize(req.getParameter("regPhone"));
        String pass = normalize(req.getParameter("regPass"));

        if (name.isEmpty() || roleName.isEmpty() || email.isEmpty() || phone.isEmpty() || pass.length() < 6) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=invalid");
            return;
        }
        if (!isValidEmail(email)) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=invalid_email");
            return;
        }
        if (!isValidPhone(phone)) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=invalid_phone");
            return;
        }
        if (!isAllowedRole(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=role");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            int roleId = LookupUtil.requireIdByName(con, "roles", "role_id", "role_name", roleName);
            Integer existingUserId = findUserId(con, email);
            String passwordHash = PasswordUtil.hashPassword(pass);

            if (existingUserId == null) {
                try (PreparedStatement ps = con.prepareStatement(INSERT_USER_SQL)) {
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setString(3, phone);
                    ps.setString(4, passwordHash);
                    ps.setInt(5, roleId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(UPDATE_USER_SQL)) {
                    ps.setString(1, name);
                    ps.setString(2, phone);
                    ps.setString(3, passwordHash);
                    ps.setInt(4, roleId);
                    ps.setInt(5, existingUserId.intValue());
                    ps.executeUpdate();
                }
            }

            resp.sendRedirect(req.getContextPath() + "/login.html?success=registered");
        } catch (SQLIntegrityConstraintViolationException e) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=exists");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Integer findUserId(Connection con, String email) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(FIND_USER_SQL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Integer.valueOf(rs.getInt("user_id"));
                }
                return null;
            }
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isAllowedRole(String roleName) {
        return "Student".equals(roleName) || "Alumni".equals(roleName) || "Placement Officer".equals(roleName);
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    private boolean isValidPhone(String phone) {
        return phone.matches("^\\d{10}$");
    }
}
