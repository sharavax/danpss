package com.danpss.servlets;

import com.danpss.util.DBUtil;
import com.danpss.util.PasswordUtil;

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

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final String LOGIN_SQL =
            "SELECT u.user_id, u.full_name, u.password_hash, r.role_name " +
            "FROM users u " +
            "JOIN roles r ON r.role_id = u.role_id " +
            "WHERE u.email = ?";
    private static final String UPDATE_PASSWORD_SQL = "UPDATE users SET password_hash = ? WHERE user_id = ?";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = normalize(req.getParameter("loginEmail"));
        String pass = normalize(req.getParameter("loginPass"));

        if (email.isEmpty() || pass.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login.html?error=invalid");
            return;
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            resp.sendRedirect(req.getContextPath() + "/login.html?error=invalid");
            return;
        }

        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(LOGIN_SQL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    resp.sendRedirect(req.getContextPath() + "/login.html?error=invalid");
                    return;
                }
                String storedPassword = rs.getString("password_hash");
                if (!PasswordUtil.verifyPassword(pass, storedPassword)) {
                    resp.sendRedirect(req.getContextPath() + "/login.html?error=invalid");
                    return;
                }
                if (!storedPassword.matches("(?i)^[0-9a-f]{64}$")) {
                    upgradeLegacyPassword(con, rs.getInt("user_id"), pass);
                }

                HttpSession session = req.getSession(true);
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("userName", rs.getString("full_name"));
                session.setAttribute("userRole", rs.getString("role_name"));
                session.setAttribute("userEmail", email);
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private void upgradeLegacyPassword(Connection con, int userId, String pass) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(UPDATE_PASSWORD_SQL)) {
            ps.setString(1, PasswordUtil.hashPassword(pass));
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
