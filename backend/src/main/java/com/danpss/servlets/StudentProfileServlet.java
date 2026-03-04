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

@WebServlet(name = "StudentProfileServlet", urlPatterns = {"/student/profile"})
public class StudentProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String name = req.getParameter("studentName");
        String email = req.getParameter("studentEmail");
        String phone = req.getParameter("studentPhone");
        String gradYear = req.getParameter("studentGraduationYear");
        String dept = req.getParameter("studentDepartment");
        String company = req.getParameter("studentCompany");
        String designation = req.getParameter("studentDesignation");
        String experience = req.getParameter("studentExperience");
        String skills = req.getParameter("studentSkills");

        String insert = "INSERT INTO students (name,email,phone,graduation_year,department,company,designation,experience,skills) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(insert)){
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, gradYear);
            ps.setString(5, dept);
            ps.setString(6, company);
            ps.setString(7, designation);
            ps.setString(8, experience);
            ps.setString(9, skills);
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/index.html");
        } catch (Exception e){
            throw new ServletException(e);
        }
    }
}
