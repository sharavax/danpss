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

@WebServlet(name = "AlumniRegisterServlet", urlPatterns = {"/alumni/register"})
public class AlumniRegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String name = req.getParameter("alumniName");
        String email = req.getParameter("alumniEmail");
        String phone = req.getParameter("alumniPhone");
        String gradYear = req.getParameter("alumniGraduationYear");
        String dept = req.getParameter("alumniDepartment");
        String company = req.getParameter("alumniCompany");
        String designation = req.getParameter("alumniDesignation");
        String experience = req.getParameter("alumniExperience");
        String pass = req.getParameter("alumniPass");

        String insert = "INSERT INTO alumni (name,email,phone,graduation_year,department,company,designation,experience,password) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(insert)){
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, gradYear);
            ps.setString(5, dept);
            ps.setString(6, company);
            ps.setString(7, designation);
            ps.setString(8, experience);
            ps.setString(9, pass);
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/login.html");
        } catch (Exception e){
            throw new ServletException(e);
        }
    }
}
