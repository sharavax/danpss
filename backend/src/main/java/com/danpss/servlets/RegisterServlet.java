package com.danpss.servlets;

import com.danpss.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLIntegrityConstraintViolationException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String name = req.getParameter("regName");
        String role = req.getParameter("role");
        String email = req.getParameter("regEmail");
        String phone = req.getParameter("regPhone");
        String pass = req.getParameter("regPass");

        String insert = "INSERT INTO users (name, role, email, phone, password) VALUES (?,?,?,?,?)";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(insert)){
            ps.setString(1, name);
            ps.setString(2, role);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, pass);
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/login.html");
        } catch (SQLIntegrityConstraintViolationException e) {
            resp.sendRedirect(req.getContextPath() + "/register.html?error=exists");
        } catch (Exception e){
            throw new ServletException(e);
        }
    }
}
